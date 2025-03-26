package App::Dn::Clipboard::Select;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.2');
use namespace::clean;
use App::Dn::Clipboard::MenuItem
    ;    # NOTE: ignore syntax warning (see note below)
use Const::Fast;
use Feature::Compat::Try;
use MooX::HandlesVia;
use Tk;
use Types::Standard;

const my $TRUE       => 1;
const my $FALSE      => 0;
const my $DEFAULT_BG => 'light gray';
const my $DEFAULT_FG => 'black';
const my $FONT_NAME  => 'Bitstream Vera Sans Mono';
const my $FONT_SIZE  => 12;
const my $SEARCH_BG  => $DEFAULT_FG;                  # black
const my $SEARCH_FG  => 'white';
const my $VAL_BOTTOM => 'bottom';
const my $VAL_END    => 'end';
const my $VAL_NINE   => 9;
const my $VAL_TOP    => 'top';
const my $VAL_W      => 'w';                          # }}}1

use Data::Dumper::Simple;

# attributes

# items    {{{1
has 'items' => (
  is  => 'ro',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf ['App::Dn::Clipboard::MenuItem'],
  ],
  required      => $TRUE,
  handles_via   => 'Array',
  handles       => { _items => 'elements' },
  documentation => 'Menu items',
);

# prompt    {{{1
has 'prompt' => (
  is            => 'ro',
  isa           => Types::Standard::Str,
  required      => $TRUE,
  documentation => 'Menu prompt',
);

# title    {{{1
has 'title' => (
  is            => 'ro',
  isa           => Types::Standard::Str,
  required      => $TRUE,
  documentation => 'Menu title',
);    # }}}1

# method

# run()
#
# does:   select item from menu
# params: nil
# prints: error messages
# return: scalar string (selected item) or FALSE (no item selected)
sub run ($self) {

  # variables    {{{1
  my @items  = $self->_items;
  my $font   = [ $FONT_NAME, $FONT_SIZE ];
  my $title  = $self->title;
  my $prompt = $self->prompt;
  my $search = q{};
  my $selection;
  my $index;

  # interface widgets    {{{1

  # • main window    {{{2
  my $mw = MainWindow->new(-class => 'Perl/Tk widget');
  $mw->title($title);

  # • prompt label    {{{2
  $mw->Label(-text => $prompt)
      ->pack(-side => $VAL_TOP, -expand => $TRUE, -anchor => $VAL_W);

  # • instruction labels    {{{2
  my @instructions = (
    '[Hotkey]: select corresponding option',
    'Enter: accept default option',
    'Escape: abort selection',
  );
  for my $instruction (@instructions) {
    $mw->Label(-text => "\N{BULLET} $instruction")
        ->pack(-side => $VAL_TOP, -expand => $TRUE, -anchor => $VAL_W);
  }

  # • listbox    {{{2
  my $lb = $mw->Scrolled(
    'Listbox',
    -scrollbars => 'osoe',      # os=south/below, oe=east/right
    -selectmode => 'single',    # select single item
    -font       => $font,
    -height     => 0,           # fit all items
    -width      => 0,           # fit longest item
  )->pack(-side => 'left');
  my $default_item_index;
  my @contents;
  $index = 0;
  for my $item (@items) {
    my ($type, $hotkey, $value, $default) =
        ($item->type, $item->hotkey, $item->value, $item->default);
    if   ($type eq 'option') { push @contents, "[$hotkey] $value"; }
    else                     { push @contents, "[$hotkey] $value -->"; }
    if ($default) { $default_item_index = $index; }
    ++$index;
  }
  $lb->insert($VAL_END, @contents);    # load menu items
  $lb->see($default_item_index);
  $lb->activate($default_item_index);
  $lb->selectionSet($default_item_index);    # pre-select default option

  # actions    {{{1

  # • [Escape]    {{{2
  # •• mimic action of Cancel button, i.e., abort

  my sub _cancel () {
    if (Tk::Exists($mw)) { $mw->destroy; }
    return;
  }
  $mw->bind('<KeyRelease-Escape>' => sub { _cancel() });

  # • [Return]    {{{2
  # •• mimic action of Ok button, i.e., accept selection

  my sub _ok () {
    try {
      my $selection_index = ($lb->curselection)[0];
      $selection = $items[$selection_index];
    }
    catch ($e) { };
    if (Tk::Exists($mw)) { $mw->destroy; }
    return;
  }
  $mw->bind('<KeyRelease-Return>' => sub { _ok() });

  # • hotkeys    {{{2
  # •• tk passes Listbox object as first parameter to anonymous sub in binding
  # •• tk passes $index as second parameter to anonymous sub in binding
  # •• skip activating/setting hotkey selection because window is destroyed
  #    too quickly to see it
  $index = 0;
  for my $item (@items) {
    my @hotkeys = (lc $item->hotkey, uc $item->hotkey);
    for my $hotkey (@hotkeys) {
      $mw->bind(
        "<KeyRelease-$hotkey>" => [
          sub {
            my (undef, $hotkey_index) = (shift, shift);
            $selection = $items[$hotkey_index];
            if (Tk::Exists($mw)) { $mw->destroy; }
            return;
          },
          $index,
        ],
      );
    }
    ++$index;
  }

  # display menu    {{{1
  $lb->focus;
  MainLoop;

  # report result    {{{1
  return $selection;    # }}}1

}

1;

#  NOTE: ignore "BEGIN failed" syntax warnings
# • the script that loaded App::Dn::Clipboard::Load did so by adding its
#   directory to @INC
# • App::Dn::Clipboard::* are in the same directory, but the perlcritic
#   static analyser does not know that, hence the error

# POD    {{{1

__END__

=head1 NAME

App::Dn::Clipboard::Select - user selects a value from a menu

=head1 VERSION

This documentation is for C<App::Dn::Clipboard::Select> version 0.1.

=head1 SYNOPSIS

    use App::Dn::Clipboard::Select;
    my $selection = App::Dn::Clipboard::Select->new(
      items  => [@items],
      prompt => 'Select item',
      title  => "Load Clipboard :: $menu_name",
    )->run;

=head1 DESCRIPTION

The user selects a value from a menu by pressing its hotkey.

The class part of the X11 WM_CLASS property for the menu is set to
"Perl/Tk widget".

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

=head3 items

Menu items. Arrayref of L<App::Dn::Clipboard::MenuItem> objects.
Required, non-empty.

=head3 prompt

Menu prompt. Scalar string. Required. Non-empty.

=head3 title

Menu title. Scalar string. Required, non-empty.

=head2 Attributes

None.

=head2 Configuration files

None used.

=head2 Environment variables

None used.

=head1 SUBROUTINES/METHODS

=head2 run()

This is the only public method.
The user selects a menu item as described in L<DESCRIPTION>.

=head3 Parameters

Nil.

=head3 Prints

Error messages.

=head3 Returns

L<App::Dn::Clipboard::MenuItem> object (selected item)
or undef (no item selected).

=head1 DIAGNOSTICS

This module does not emit any warning or error messages.

Subsidiary modules may do so.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

App::Dn::Clipboard::MenuItem, Const::Fast, Feature::Compat::Try, Moo,
MooX::HandlesVia, namespace::clean, strictures, Tk, Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
