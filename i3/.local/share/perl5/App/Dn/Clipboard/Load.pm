package App::Dn::Clipboard::Load;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.2');
use namespace::clean -except => [ '_options_data', '_options_config' ];
use App::Dn::Clipboard::Config; # NOTE: ignore syntax warning (see note below)
use App::Dn::Clipboard::MenuItem;
use App::Dn::Clipboard::MenuItems;
use Clipboard;
use Const::Fast;
use MooX::HandlesVia;
use Types::Standard;
use MooX::Options (
  authors     => 'David Nebauer <david at nebauer dot org>',
  description => 'The user selects an item from a menu system and'
      . ' it is pasted to the system clipboard.',
  protect_argv => 0,
);

const my $TRUE        => 1;
const my $CONFIG_STEM => 'load-clipboard-data';
const my $KEY_DEFAULT => 'default';
const my $KEY_HOTKEY  => 'hotkey';
const my $KEY_MENU    => 'menu';
const my $KEY_SUBMENU => 'submenu';
const my $KEY_TYPE    => 'type';
const my $KEY_VALUE   => 'value';
const my $MENU_MAIN   => 'Main';                  # }}}1

# attributes

# _add_menu_items($item), _menu_items($name), _has_menu($name)    {{{1
has '_menus_hash' => (
  is  => 'rw',
  isa => Types::Standard::HashRef [
    Types::Standard::InstanceOf ['App::Dn::Clipboard::MenuItems'],
  ],
  lazy        => $TRUE,
  default     => sub { {} },
  handles_via => 'Hash',
  handles     => {
    _add_menu_items => 'set',       # ($name => $item)
    _menu_items     => 'get',       # ($name) --> $item
    _has_menu       => 'exists',    # ($name) --> bool
  },
  doc => 'Menu items',
);                                  # }}}1

# methods

# run()    {{{1
#
# does:   main method
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub run ($self) {

  # load menus
  $self->_process_config_data;

  # select from menu
  my $selection = $self->_select_from_menu($MENU_MAIN);

  # copy selected value to clipboard
  if ($selection) {
    Clipboard->copy_to_all_selections($selection);
  }

  return;
}

# _check_config_data($data)    {{{1
#
# does:   check validity of config data
# params: $data - configuration data to check [arrayref, required]
# prints: error messages
# return: bool, but dies on error
sub _check_config_data ($self, $data) {    ## no critic (Subroutines::ProhibitExcessComplexity)

  # test: data cannot be empty
  if (not $data) { die "No configuration data retrieved\n"; }

  # test: must be arrayref
  my $ref = ref $data;
  if (not $ref) { die "Expected arrayref config data, got a non-ref\n"; }

  # cycle through menu items
  # - ignore empty items used as spacers in config file
  my (
    %menus_defined, %menus_called, %menu_defaults,
    %menu_hotkeys,  %menu_values,  %menu_names,
  );
  my @required_keys  = qw(menu hotkey type value default);
  my @non_empty_keys = qw(menu hotkey type value);
  my $valid_type     = qr{option|submenu}xsm;
  my $item_number    = 0;
  for my $item_hashref (@{$data}) {
    my %item = %{$item_hashref};
    ++$item_number;
    if (not %item) { next; }

    # test: must have all required keys
    for my $key (@required_keys) {
      if (not(exists $item{$key})) {
        die "Config item $item_number is missing a '$key' key\n";
      }
    }

    # test: valid key values
    for my $key (@non_empty_keys) {
      if (not $item{$key}) {
        die "Config item $item_number has an empty '$key' value\n";
      }
      my $item_type = $item{$KEY_TYPE};
      if ($item_type !~ $valid_type) {
        die "Config item $item_number has invalid type '$item_type'\n";
      }
    }

    # prep: defined menus match defined menus
    my $menu_name = $item{$KEY_MENU};
    $menus_defined{$menu_name} = $TRUE;
    if ($item{$KEY_TYPE} eq $KEY_SUBMENU) {
      $menus_called{ $item{$KEY_VALUE} } = $TRUE;
    }

    # prep: counts of default items per menu
    $menu_names{$menu_name} = $TRUE;
    if ($item{$KEY_DEFAULT}) { ++$menu_defaults{$menu_name} }

    # prep: counts of individual hotkeys and values per menu
    ++$menu_hotkeys{$menu_name}{ $item{$KEY_HOTKEY} };
    ++$menu_values{$menu_name}{ $item{$KEY_VALUE} };
  }

  # test: defined menus match defined menus
  # - the 'Main' menu us not called by any other menu
  delete $menus_defined{$MENU_MAIN};
  for my $called_menu (keys %menus_called) {
    if (not(exists $menus_defined{$called_menu})) {
      die "Menu '$called_menu' is called but not defined in config data\n";
    }
  }
  for my $defined_menu (keys %menus_defined) {
    if (not(exists $menus_called{$defined_menu})) {
      die "Menu '$defined_menu' is defined but not called in config data\n";
    }
  }

  # test: counts of default items per menu
  for my $menu_name (keys %menu_names) {
    my $defaults = scalar $menu_defaults{$menu_name};
    if (not(defined $defaults)) {
      die "Menu '$menu_name' has no default item\n";
    }
    if ($defaults > 1) {
      die "Menu '$menu_name' has $defaults default items\n";
    }
  }

  # test: counts of individual hotkeys and values per menu
  for my $menu_name (keys %menu_names) {
    my $count;
    for my $hotkey (keys %{ $menu_hotkeys{$menu_name} }) {
      $count = $menu_hotkeys{$menu_name}->{$hotkey};
      if ($count > 1) {
        die "Menu '$menu_name' has $count items with hotkey '$hotkey'\n";
      }
    }
    for my $value (keys %{ $menu_values{$menu_name} }) {
      $count = $menu_values{$menu_name}->{$value};
      if ($count > 1) {
        die "Menu '$menu_name' has $count items with value '$value'\n";
      }
    }
  }

  return $TRUE;
}

# _process_config_data($menus, $name, $data)    {{{1
#
# does:   load menu data from configuration file
# params: $menus - all menus [hashref of name => data]
#         $name  - menu name [string]
#         $data  - menu data [arrayref]
# prints: nil
# return: n/a, dies on failure
sub _process_config_data ($self) {

  # get configuration data
  my $stem = $CONFIG_STEM;
  my $data = App::Dn::Clipboard::Config->new(stem => $stem)->run;

  # check validity of config data
  $self->_check_config_data($data);

  # cycle through configured menu items, loading menus
  for my $item_hashref (@{$data}) {
    my %item = %{$item_hashref};

    # ignore empty items used as spacers in config file
    if (not %item) { next; }

    # add new menu if not already added
    my $menu_name = $item{$KEY_MENU};
    if (not $self->_has_menu($menu_name)) {
      my $menu_items = App::Dn::Clipboard::MenuItems->new;
      $self->_add_menu_items($menu_name => $menu_items);
    }

    # add menu item to menu
    my $menu_item = App::Dn::Clipboard::MenuItem->new(
      menu    => $menu_name,
      hotkey  => $item{$KEY_HOTKEY},
      type    => $item{$KEY_TYPE},
      value   => $item{$KEY_VALUE},
      default => $item{$KEY_DEFAULT},
    );
    $self->_menu_items($menu_name)->add_item($menu_item);
  }
  return;
}

# _select_from_menu($menu_name)    {{{1
#
# does:   select item from menu
# params: $menu_name - menu name
# prints: nil, except error messages
# return: if selection then App::Dn::Clipboard::MenuItem
#         else              undef
# notes:  function may recurse if user selects a submenu
sub _select_from_menu ($self, $menu_name) {

  # select item from menu
  # • returns an App::Dn::Clipboard::MenuItem object or undef
  my $selection = $self->_menu_items($menu_name)->select_item($menu_name);

  # if no selection made, return undef
  if (not $selection) {
    return $selection;
  }

  # if user selected an option, return the option value
  if ($selection->type eq 'option') {
    return $selection->value;
  }

  # if user selected a submenu, recurse into another menu selection
  else {
    my $submenu_name      = $selection->value;
    my $submenu_selection = $self->_select_from_menu($submenu_name);

    # if user selected a submenu option, pass option value to caller
    if ($submenu_selection) {
      return $submenu_selection;
    }

    # if user aborted the submenu, redo the current menu
    else {
      return $self->_select_from_menu($menu_name);
    }
  }
}    # }}}1

1;

#  NOTE: ignore "BEGIN failed" syntax warnings
# • the script that loaded App::Dn::Clipboard::Load did so by adding its
#   directory to @INC
# • App::Dn::Clipboard::* are in the same directory, but the perlcritic
#   static analyser does not know that, hence the error

# POD    {{{1

__END__

=head1 NAME

App::Dn::Clipboard::Load - load selected value into system clipboard

=head1 VERSION

This documentation applies to L<App::Dn::Clipboard::Load> version 0.2.

=head1 SYNOPSIS

    use App::Dn::Clipboard::Load;

    App::Dn::Clipboard::Load->new_with_options->run;

=head1 DESCRIPTION

The user selects from menus of pre-defined options. The selected option is
loaded into the system clipboard.

A submenu is indicated by an option with an appended '-->'. Selecting such an
option opens a submenu.

Menu options have a one character prefix (a hotkey) to enable quick option
selection.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

None.

=head2 Configuration files

The menu content is defined in configuration file
S<< F<~/.config/load-clipboard-data.json> >>.

The general structure of the menu is:

    [
      {
        "menu": "Main",
        "hotkey": "i",
        "type": "option",
        "value": "david@nebauer.id.au",
        "default": 1
      },
      ...
      {},
      {},
      {},
      ...
      {
        "menu": "Email",
        "hotkey": "i",
        "type": "option",
        "value": "david@nebauer.id.au",
        "default": 0
      },
      ...
    ]

While the structure is largely self-explanatory, its major features are:

=over

=item *

The data is valid JSON.

=item *

The outer data structure is an array.

=item *

Each menu item is a single hashref. (In perl a JSON object is known
as a hash. In other languages it is an associative array.)

=item *

Each menu item hashref must have the following keys:

=over

=item menu

Can be anything, but is traditionally a single word with initial
capitalisation. All items with the same menu name belong to that menu -
this is how menus are defined.

The base menu, that is, the first menu to display when this module is run,
is called "Main". This menu must be defined in the configuration file.
It is defined by having at least one menu item with a C<menu> value of "Main".

All menus except the "Main" menu must be called by at least one menu item
(see the C<submenu> menu item key).

Scalar string. Required.

=item hotkey

This single character must be unique within a menu. Char. Required.

=item type

Indicate whether the menu item represents a value for loading into the
clipboard or represents a submenu.
String. Required. Valid values: 'option', 'submenu'.

=item value

This is either the text string to be loaded into the clipboard
(for C<type> = "option") or the name of a submenu to be invoked
(C<type> = "submenu").
All called submenu names must correspond to defined menus
(see the C<menu> menu item key).
An "option" value is displayed in the menu item without alteration.
A "submenu" value is displayed in the menu item with a trailing " -->".

For "option" values there are special tokens which signify the current date in
a particular format. The menu item value must contain only the token string
with no additional characters.

Available date tokens are:

=over

=item I<%current_date_full%>

Example: 1 December 2022

=item I<%current_date_full_nbsp%>

As for "%current_date_full%" except that spaces are replaced with
non-breaking spaces

=item I<%current_date_iso%>

Example: 2022-12-01

=item I<%current_date_rfc%>

Example: Thu,  1 Dec 2022 18:51:37 +0930

The system time zone is used and day numbers less than 10 have a leading space.

=back

=item default

Whether the menu item is the default selection for the menu.
At least one menu item per menu can have a true value.
No more than one menu item per menu can have a true value.
Required. Boolean. By convention 1 is true while 0 is false.

=back

=back

Menu item hashrefs from different lists can be interspersed with each other,
but the order of menu items in each menu reflects the order of the
underlying hashrefs in the configuration file.

Empty hashrefs are ignored. If all item hashrefs are grouped according to menu,
the grouped items from each menu can be separated by multiple empty hashrefs
as shown in the example above.

=head2 Environment variables

None used.

=head2 i3 window manager

In the i3 window manager the wrapper script can be invoked from a binding that
can be set in the F<config> file. For example, to launch it with the F2 key use
the following configuration command:

    set $loader_launcher ~/.local/bin/i3-my-load-clipboard
    bindsym F2 exec --no-startup-id $loader_launcher

The wrapper script launches this script in an alacritty instance. To ensure the
terminal window is free-floating add a line like this to the i3wm F<config>
file:

    for_window [class="Clipboard_Loader" instance="Clipboard_Loader"] \\
               floating enable, resize set 1000 600

Adjust the C<class> and C<instance> values as appropriate.

If the picom compositor is being used add a line like the following to its
S<< F<picom.conf> >> file to ensure the alacritty terminal is opaque:

    opacity-rule = [ "100:class_g *?= 'Clipboard_Loader'" ];

Adjust the C<class> value as appropriate.

=head1 SUBROUTINES/METHODS

=head2 run()

The only public method. This method enables the loading of a selected value
into the system clipboard as described in L</DESCRIPTION>.

=head1 DIAGNOSTICS

=head2 Expected arrayref config data, got a non-ref

=head2 No configuration data retrieved

These fatal errors indicate problems retrieving configuration data.
Additional errors may be generated by the L<App::Dn::Clipboard::Config> module.

=head2 Config item NUMBER has an empty 'KEY' value

=head2 Config item NUMBER has invalid type 'ITEM_TYPE'

=head2 Config item NUMBER is missing a 'key' key

=head2 Menu 'CALLED_MENU' is called but not defined in config data

=head2 Menu 'DEFINED_MENU' is defined but not called in config data

=head2 Menu 'MENU_NAME' has NUMBER default items

=head2 Menu 'MENU_NAME' has NUMBER items with hotkey 'HOTKEY'

=head2 Menu 'MENU_NAME' has NUMBER items with value 'VALUE'

=head2 Menu 'MENU_NAME' has no default item

These fatal errors indicate validity problems with the menu and menu item data
defined in the configuration file.

I<Subsidiary modules may emit their own warning and error messages.>

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

App::Dn::Clipboard::Config, App::Dn::Clipboard::MenuItem,
App::Dn::Clipboard::MenuItems, Clipboard, Const::Fast, Moo, MooX::HandlesVia,
MooX::Options, namespace::clean, strictures.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2022 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
