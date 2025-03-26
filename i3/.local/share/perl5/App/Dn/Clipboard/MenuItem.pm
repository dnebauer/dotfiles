package App::Dn::Clipboard::MenuItem;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.2');
use namespace::clean;
use Const::Fast;
use Types::Standard;

const my $TRUE => 1;    # }}}1

# attributes

# menu    {{{1
has 'menu' => (
  is       => 'ro',
  isa      => Types::Standard::Str,
  required => $TRUE,
  doc      => 'Name of menu to which item belongs',
);

# hotkey    {{{1
has 'hotkey' => (
  is       => 'ro',
  isa      => Types::Standard::StrMatch [qr{\A[[:lower:]]\z}xsm],
  required => $TRUE,
  doc      => 'Menu item hotkey (single character)',
);

# type    {{{1
has 'type' => (
  is       => 'ro',
  isa      => Types::Standard::StrMatch [qr{\Aoption|submenu\z}xsm],
  required => $TRUE,
  doc      => q{Menu item type ['option' or 'submenu']},
);

# value    {{{1
has 'value' => (
  is       => 'rw',                 # need to change when process value tokens
  isa      => Types::Standard::Str,
  required => $TRUE,
  doc      => 'Menu item value (submenu name or item string)',
);

# default    {{{1
has 'default' => (
  is       => 'ro',
  isa      => Types::Standard::Bool,
  required => $TRUE,
  doc      => 'Whether this item is the default menu item',
);    # }}}1

1;

# POD    {{{1

__END__

=head1 NAME

App::Dn::Clipboard::MenuItem - model the properties of a menu item

=head1 VERSION

This documentation applies to L<App::Dn::Clipboard::MenuItem> version 0.2.

=head1 SYNOPSIS

    use App::Dn::Clipboard::MenuItem;
    # ...
    my $menu_item = App::Dn::Clipboard::MenuItem->new(
      menu    => $menu_name,
      hotkey  => $item{$KEY_HOTKEY},
      type    => $item{$KEY_TYPE},
      value   => $item{$KEY_VALUE},
      default => $item{$KEY_DEFAULT},
    );

=head1 DESCRIPTION

This module models a menu item.
It is used by L<App::Dn::Clipboard::Load> and L<App::Dn::Clipboard::MenuItems>.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

All properties are required.

=head3 menu

Can be anything, but is traditionally a single word with initial
capitalisation. All items with the same menu name belong to that menu -
this is how menus are defined.

The base menu, that is, the first menu to display when this module is run,
is called "Main". This menu must be defined in the configuration file.
It is defined by having at least one menu item with a C<menu> value of "Main".

All menus except the "Main" menu must be called by at least one menu item
(see the C<submenu> menu item key).

=head3 hotkey

This single character must be unique within a menu.

=head3 type

Indicate whether the menu item represents a value for loading into the
clipboard or represents a submenu.
Valid values: 'option', 'submenu'.

=head3 value

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

=back

=head3 default

Whether the menu item is the default selection for the menu.
At least one menu item per menu can have a true value.
No more than one menu item per menu can have a true value.
Required. Boolean. By convention 1 is true while 0 is false.

=head2 Configuration files

None used.

=head2 Environmental variables

None used.

=head1 SUBROUTINES/METHODS

None defined.

=head1 DIAGNOSTICS

No warning or error messages are generated.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

Const::Fast, Moo, namespace::clean, strictures, Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2022 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
