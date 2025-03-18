package App::Dn::RTNG::Stations;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;
use App::Dn::RTNG::Station;
use MooX::HandlesVia;
use Types::Standard;    # }}}1

# attributes

# add_station    {{{1
has '_stations_arrayref' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf ['App::Dn::RTNG::Station'],
  ],
  default     => sub { [] },
  handles_via => 'Array',
  handles     => {
    add_station => 'push',        # (station)
    _stations   => 'elements',    # () --> list
  },
  doc => 'Details of multiple stations, i.e., all stations in a group',
);                                # }}}1

# methods

# station_names()    {{{1
#
# does:   extract list of station names
# params: nil
# prints: nil
# return: list of station names
sub station_names ($self) {
  my @station_names;
  for my $station ($self->_stations) {
    push @station_names, $station->name;
  }
  return @station_names;
}

1;

# POD    {{{1

__END__

=head1 NAME

App::Dn::RTNG::Stations - utility module modelling a group of stations

=head1 VERSION

This documentation is for C<App::Dn::RTNG::Stations> version 0.1.

=head1 SYNOPSIS

    use App::Dn::RTNG::Stations;

=head1 DESCRIPTION

Store details of a group of radio stations defined in S<Radiotray NG>.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

None.

=head2 Attributes

None.

=head2 Configuration files

None used.

=head2 Environment variables

None used.

=head1 SUBROUTINES/METHODS

=head2 add_station($station)

Add a station.

=head3 Parameters

=over

=item $station

Station to add. An L<App::Dn::RTNG::Station> object. Required.

=back

=head3 Prints

Nil.

=head3 Returns

N/A.

=head2 station_names()

Extract a list of station names.

=head3 Parameters

Nil.

=head3 Prints

Nil.

=head3 Returns

List of station names.

=head1 DIAGNOSTICS

No failure modes are documented.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

App::Dn::RTNG::Station, namespace::clean, Moo, MooX::HandlesVia, strictures,
Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
