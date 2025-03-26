package App::Dn::Clipboard::MenuItems;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.2');
use namespace::clean;
use App::Dn::Clipboard::MenuItem
    ;    # NOTE: ignore syntax warning (see note below)
use App::Dn::Clipboard::Select;
use Const::Fast;
use DateTime;
use DateTime::TimeZone;
use English;
use MooX::HandlesVia;
use Types::Standard;

const my $TRUE => 1;    # }}}1

use Data::Dumper::Simple;

# attributes

# add_item($item), items()    {{{1
has '_menu_items_array' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf ['App::Dn::Clipboard::MenuItem'],
  ],
  required    => $TRUE,
  default     => sub { [] },
  handles_via => 'Array',
  handles     => {
    add_item => 'push',        # ($item) --> item_count
    _items   => 'elements',    # () --> @items
  },
  doc => 'Menu items',
);

# _token_value($name), _has_token($name)    {{{1
has '_tokens_hash' => (
  is      => 'rw',
  isa     => Types::Standard::HashRef [Types::Standard::Str],
  lazy    => $TRUE,
  default => sub {
    {
      my %tokens;
      my $time_zone = DateTime::TimeZone->new(name => 'local')->name();
      my $today     = DateTime->now(time_zone => $time_zone);
      $tokens{'%current_date_iso%'} = $today->ymd;
      my $full_date = $today->strftime('%d %B %Y');
      my $full_trim = $full_date =~ s/\A0//rxsm;
      $tokens{'%current_date_full%'} = $full_trim;
      my $full_replace = $full_trim =~ s/\s/\N{NO-BREAK SPACE}/grxsm;
      $tokens{'%current_date_full_nbsp%'} = $full_replace;
      $tokens{'%current_date_rfc%'} = $today->strftime('%a, %d %b %Y %T %z');
      return {%tokens};
    }
  },
  handles_via => 'Hash',
  handles     => {
    _token_value => 'get',       # ($name) --> $value
    _has_token   => 'exists',    # ($name) --> bool
  },
  doc => 'Token values',
);                               # }}}1

# methods

# select_item($menu_name)    {{{1
#
# does:   user selects an item from this menu
# params: $menu_name - name of menu [scalar string, required]
# prints: error messages
# return: if option selected, then App::Dn::Clipboard::MenuItem
#         else undef
sub select_item ($self, $menu_name) {

  # replace tokens
  my @items = $self->_items;
  for my $item (@items) {
    my $candidate_token_name = $item->value;
    if ($self->_has_token($candidate_token_name)) {
      my $token_value = $self->_token_value($candidate_token_name);
      $item->value($token_value);
    }
  }

  # make selection
  my $selection = App::Dn::Clipboard::Select->new(
    items  => [@items],
    prompt => 'Select item',
    title  => "Load Clipboard :: $menu_name",
  )->run;

  return $selection;
}

1;

#  NOTE: ignore "Can't locate" syntax warnings
# • the script that loaded App::Dn::Clipboard::MenuItems did so by adding
#   its directory to @INC
# • App::Dn::Clipboard::* are in the same directory, but the perlcritic
#   static analyser does not know that, hence the error

# POD    {{{1

__END__

=head1 NAME

App::Dn::Clipboard::MenuItems - models a group of items in a menu

=head1 VERSION

This documentation applies to L<App::Dn::Clipboard::MenuItems> version 0.2.

=head1 SYNOPSIS

    use App::Dn::Clipboard::MenuItems;
    ...
    my $menu_items = App::Dn::Clipboard::MenuItems->new;
    ...
    $self->_menu_items($menu_name)->add_item($menu_item);
    ...
    $self->_add_menu_items($menu_name => $menu_items);

=head1 DESCRIPTION

This module models a group of menu items in a single menu.
It is used by L<App::Dn::Clipboard::Load>.

=head1 CONFIGURATION

=head2 Properties

None used.

=head2 Configuration files

None used.

=head2 Environment variables

None used.

=head1 SUBROUTINES/METHODS

=head2 add_item($item)

Add a menu item.

=head3 Parameters

=over

=item $item

A menu item. An L<App::Dn::Clipboard::MenuItem> object. Required.

=back

=head3 Prints

Nil.

=head3 Returns

N/A.

=head2 select_item($menu_name)

The user selects an item from this menu.

=head3 Parameters

=over

=item $menu_name

Name of menu. String. Required.

=back

=head3 Prints

Error messages on failure.

=head3 Returns

L<App::Dn::Clipboard::MenuItem> item if selection is made.

Undef if no selection is made.

=head1 DIAGNOSTICS

This module does not emit any warning or error messages.

Subsidiary module may do so.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

App::Dn::Clipboard::MenuItem, Const::Fast, DateTime, DateTime::TimeZone,
English, Moo, MooX::HandlesVia, namespace::clean, strictures, Types::Standard,
version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2022 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
