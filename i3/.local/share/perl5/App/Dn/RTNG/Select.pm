package App::Dn::RTNG::Select;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;
use charnames qw(:full);
use Const::Fast;
use English;
use MooX::HandlesVia;
use Feature::Compat::Try;
use Tk;
use Types::Standard;

const my $TRUE       => 1;
const my $FALSE      => 0;
const my $DEFAULT_BG => 'light gray';
const my $DEFAULT_FG => 'black';
const my $FONT_NAME  => 'LucidaSans';
const my $FONT_SIZE  => 12;
const my $SEARCH_BG  => $DEFAULT_FG;    # black
const my $SEARCH_FG  => 'white';
const my $VAL_BOTTOM => 'bottom';
const my $VAL_END    => 'end';
const my $VAL_NINE   => 9;
const my $VAL_TOP    => 'top';
const my $VAL_W      => 'w';            # }}}1

# attributes

# items    {{{1
has 'items' => (
  is            => 'ro',
  isa           => Types::Standard::ArrayRef [Types::Standard::Str],
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
  my @items          = sort $self->_items;
  my $made_selection = $FALSE;
  my $font           = [ $FONT_NAME, $FONT_SIZE ];
  my $title          = $self->title;
  my $prompt         = $self->prompt;
  my $search         = q{};
  my $selection;

  # interface widgets    {{{1

  # • main window    {{{2
  my $mw = MainWindow->new(-class => 'Perl/Tk widget');
  $mw->title($title);

  # • prompt label    {{{2
  $mw->Label(-text => $prompt)
      ->pack(-side => $VAL_TOP, -expand => $TRUE, -anchor => $VAL_W);

  # • instruction labels    {{{2
  my @instructions = (
    "\N{UPWARDS ARROW}\N{DOWNWARDS ARROW}: move up|down options",
    'Space: select option',
    'Enter: accept selection',
    'Escape: abort',
    '[A-Za-z0-9.-]: iterative search',
  );
  for my $instruction (@instructions) {
    $mw->Label(-text => "\N{BULLET} $instruction")
        ->pack(-side => $VAL_TOP, -expand => $TRUE, -anchor => $VAL_W);
  }

  # • search label    {{{2
  my $sl = $mw->Label(-textvariable => \$search)
      ->pack(-side => $VAL_TOP, -expand => $TRUE, -anchor => $VAL_W);

  # • listbox    {{{2
  my $lb = $mw->Scrolled(
    'Listbox',
    -scrollbars => 'osoe',      # os=south/below, oe=east/right
    -selectmode => 'single',    # select single item
    -font       => $font,
    -width      => 0,           # fit longest item
  )->pack(-side => 'left');
  $lb->insert($VAL_END, @items);    # load menu items

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
    $made_selection = $TRUE;
    try { $selection = $lb->get($lb->curselection); }
    catch ($e) { };
    if (Tk::Exists($mw)) { $mw->destroy; }
    return;
  }
  $mw->bind('<KeyRelease-Return>' => sub { _ok() });

  # • alphanum    {{{2
  # •• iterative search for matching menu item

  my sub _search_items ($term) {
    my $found_match = $FALSE;
    for my $index (0 .. $#items) {
      if ($items[$index] =~ /\A$search/xsmi) {
        $found_match = $TRUE;
        $lb->see($index);
        $lb->selectionClear(0, $VAL_END);
        $lb->selectionSet($index);
        $sl->configure(-fg => $SEARCH_FG, -bg => $SEARCH_BG);
        last;
      }
    }
    return $found_match;
  }

  my sub _search ($key) {

    # add key to previous search term and search
    # • search term is displayed in search label ('$sl')
    $search .= $key;
    my $match_found = _search_items($search);
    if ($match_found) { return; }

    # try the key alone
    $search      = $key;
    $match_found = _search_items($search);
    if ($match_found) { return; }

    # if no match on key alone, discard it
    $search = q{};
    $sl->configure(-fg => $DEFAULT_FG, -bg => $DEFAULT_BG);

    return;
  }

  # •• unable to bind Space as its built-in action (to activate
  #    current menu item) overrides any binding
  my @keys;
  push @keys, ('A' .. 'Z'), ('a' .. 'z'), (0 .. $VAL_NINE), q{-};
  my %bind_keys = map { $ARG => $ARG } @keys;
  $bind_keys{'period'} = q{.};
  for my $bind_key (keys %bind_keys) {
    my $search_key = $bind_keys{$bind_key};
    $mw->bind("<KeyRelease-$bind_key>" => sub { _search($search_key) });
  }

  # display menu    {{{1
  $lb->focus;
  MainLoop;

  # report result    {{{1
  return $selection;    # }}}1

}

1;

# POD    {{{1

__END__

=head1 NAME

App::Dn::RTNG::Select - user selects a value from a menu

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

The user selects a value from a menu.
The menu displays instructions for its use.
Iterative search is available.

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

charnames, Const::Fast, English, Feature::Compat::Try, Moo, MooX::HandlesVia,
namespace::clean, strictures, Tk, Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
