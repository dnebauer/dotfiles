package App::Dn::RTNG::Select;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;
use Const::Fast;
use English;
use MooX::HandlesVia;
use Feature::Compat::Try;
use Tk;
use Types::Standard;

const my $TRUE       => 1;
const my $FALSE      => 0;
const my $FONT_NAME  => 'Bitstream Vera Sans Mono';
const my $FONT_SIZE  => 12;
const my $RANGE_NINE => 9;
const my $VAL_TOP    => 'top';
const my $VAL_W      => 'w';

const my $AVAILABLE_HOTKEYS_COUNT => 62;    # a-z + A-Z + 0-9    }}}1

# attributes

# items    {{{1
has 'items' => (
  is            => 'ro',
  isa           => Types::Standard::ArrayRef [Types::Standard::Str],
  required      => $TRUE,
  handles_via   => 'Array',
  handles       => { _items_unsorted => 'elements' },
  documentation => 'Menu items',
);

sub _items ($self) {
  my @items_sorted = sort $self->_items_unsorted;
  return @items_sorted;
}

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
);

# _add_hotkeys(), _hotkeys()    {{{1
has '_hotkeys_arrayref' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::StrMatch [qr{\A[[:alnum:]]\z}xsm]
  ],
  lazy        => $TRUE,
  default     => sub { [] },
  handles_via => 'Array',
  handles     => {
    _add_hotkeys => 'push',
    _hotkeys     => 'elements',
  },
  documentation => 'Menu item hotkeys',
);    # }}}1

# method

# run()    {{{1
#
# does:   select item from menu
# params: nil
# prints: error messages
# return: scalar string (selected item) or FALSE (no item selected)
sub run ($self) {

  # variables    {{{2
  my @items  = $self->_items;
  my $font   = [ $FONT_NAME, $FONT_SIZE ];
  my $title  = $self->title;
  my $prompt = $self->prompt;
  my $selection;

  # • generate hotkeys and menu labels
  $self->_assign_hotkeys;
  my @hotkeys     = $self->_hotkeys;
  my @item_labels = $self->_item_labels;

  # interface widgets    {{{2

  # • main window    {{{3
  my $mw = MainWindow->new(-class => 'Perl/Tk widget');
  $mw->title($title);

  # • prompt label    {{{3
  $mw->Label(-text => $prompt)
      ->pack(-side => $VAL_TOP, -expand => $TRUE, -anchor => $VAL_W);

  # • instruction labels    {{{3
  my @instructions = (
    '[Hotkey]: select corresponding option',
    'Enter: accept default option',
    'Escape: abort selection',
  );
  for my $instruction (@instructions) {
    $mw->Label(-text => "\N{BULLET} $instruction")
        ->pack(-side => $VAL_TOP, -expand => $TRUE, -anchor => $VAL_W);
  }

  # • listbox    {{{3
  my $lb = $mw->Scrolled(
    'Listbox',
    -scrollbars => 'osoe',      # os=south/below, oe=east/right
    -selectmode => 'single',    # select single item
    -font       => $font,
    -height     => 0,           # fit all menu items
    -width      => 0,           # fit longest item
  )->pack(-side => 'left');
  $lb->insert('end', @item_labels);    # load menu items

  # actions    {{{2

  # • [Escape]    {{{3
  # •• mimic action of Cancel button, i.e., abort

  my sub _cancel () {
    if (Tk::Exists($mw)) { $mw->destroy; }
    return;
  }
  $mw->bind('<KeyRelease-Escape>' => sub { _cancel() });

  # • [Return]    {{{3
  # •• mimic action of Ok button, i.e., accept selection

  my sub _ok () {
    try { $selection = $lb->get($lb->curselection); }
    catch ($e) { };
    if (Tk::Exists($mw)) { $mw->destroy; }
    return;
  }
  $mw->bind('<KeyRelease-Return>' => sub { _ok() });

  # • hotkeys    {{{3
  # •• tk passes Listbox object as first parameter to anonymous sub in binding
  # •• tk passes $index as second parameter to anonymous sub in binding
  # •• skip activating/setting hotkey selection because window is destroyed
  #    too quickly to see it
  for my $index (0 .. $#hotkeys) {
    my $hotkey = $hotkeys[$index];
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

  # display menu    {{{2
  $lb->focus;
  MainLoop;

  # report result    {{{2
  return $selection;    # }}}2

}

# _assign_hotkeys()    {{{1
#
# does:   assign a unique hotkey for each menu item
# params: nil
# prints: error messages
# return: n/a, loads attribute '_hotkeys_arrayref'
sub _assign_hotkeys ($self) {

  # variables
  my @items = $self->_items;
  my (@items_alphanum, @items_chars, @hotkeys, @hotkey_candidates);
  for (0 .. $#items) { push @hotkeys, q{}; }
  push @hotkey_candidates, ('a' .. 'z'), (0 .. $RANGE_NINE), ('A' .. 'Z');
  my %available_candidates = map { $ARG => $TRUE } @hotkey_candidates;

  # check that menu size does not exceed number of available hotkeys
  my $menu_size = @items;
  if ($#items > $AVAILABLE_HOTKEYS_COUNT) {
    my $msg = "More menu items ($menu_size) than"
        . " available hotkeys ($AVAILABLE_HOTKEYS_COUNT)";
    die "$msg\n";
  }

  # get sequences of menu characters
  @items_alphanum = map { lc $ARG } map {s/[^[:alnum:]]//grxsm} @items;
  for my $item (@items_alphanum) {
    my @item_chars = split //xsm, $item;
    push @items_chars, [@item_chars];
  }

  # try assigning option characters as hotkeys
  my $loop              = 0;
  my $assigning_hotkeys = $TRUE;

  while ($assigning_hotkeys) {
    $assigning_hotkeys = $FALSE;

    # loop through options testing option char at $loop
    for my $option_index (0 .. $#items) {

      # only operate on options without a hotkey assigned
      if ($hotkeys[$option_index]) { next; }

      # try char at loop position
      my @item_chars       = @{ $items_chars[$option_index] };
      my $hotkey_candidate = $item_chars[$loop];
      if (exists $available_candidates{$hotkey_candidate}) {
        $hotkeys[$option_index] = $hotkey_candidate;
        delete $available_candidates{$hotkey_candidate};
        $assigning_hotkeys = $TRUE;
      }
    }
    ++$loop;
  }

  # for remaining options without hotkeys, pick next available in alnum order
  for my $option_index (0 .. $#items) {

    # only operate on options without a hotkey assigned
    if ($hotkeys[$option_index]) { next; }

    # get next available hotkey candidate
    my $hotkey;
    for my $hotkey_candidate (@hotkey_candidates) {
      if ($available_candidates{$hotkey_candidate}) {
        $hotkey = $hotkey_candidate;
        last;
      }
    }
    $hotkeys[$option_index] = $hotkey;
    delete $available_candidates{$hotkey};
  }

  # save hotkeys
  $self->_add_hotkeys(@hotkeys);

  return;
}

# _item_labels()    {{{1
#
# does:   create menu items using hotkeys
# params: nil
# prints: error messages
# return: list of strings
sub _item_labels ($self) {
  my @hotkeys = $self->_hotkeys;
  my @items   = $self->_items;
  my @menu_items;
  for my $index (0 .. $#items) {
    my $hotkey = $hotkeys[$index];
    my $item   = $items[$index];
    push @menu_items, "[$hotkey] $item";
  }
  return @menu_items;
}    # }}}1

1;

# POD    {{{1

__END__

=head1 NAME

App::Dn::RTNG::Select - user selects a value from a hotkey menu

=head1 VERSION

This documentation is for C<App::Dn::RTNG::Select> version 0.1.

=head1 SYNOPSIS

    use App::Dn::RTNG::Select;
    my $selection = App::Dn::RTNG::Select->new(
      items  => $items,
      prompt => $prompt,
      title  => $title,
    )->run;

=head1 DESCRIPTION

The user selects a value from a hotkey menu.
The menu displays instructions for its use.

The class part of the X11 WM_CLASS property for the menu is set to
"Perl/Tk widget".

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

=head3 items

Menu items. Arrayref of scalar strings. Required, non-empty.

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

Scalar string (selected item) or FALSE (no item selected).

=head1 DIAGNOSTICS

No failure modes are documented.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

Const::Fast, English, Feature::Compat::Try, Moo, MooX::HandlesVia,
namespace::clean, strictures, Tk, Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
