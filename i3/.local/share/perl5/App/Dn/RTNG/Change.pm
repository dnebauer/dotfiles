package App::Dn::RTNG::Change;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean -except => [ '_options_data', '_options_config' ];
use App::Dn::RTNG::Library;    # NOTE: ignore syntax warning (see note below)
use App::Dn::RTNG::Select;
use App::Dn::RTNG::Stations;
use Const::Fast;
use Types::Standard;
use MooX::Options (
  authors     => 'David Nebauer <david at nebauer dot org>',
  description => 'The user selects a bookmarked radio station defined in'
      . ' Radiotray NG and plays it. If Radiotray NG is currently playing a'
      . ' radio station it will stop it and start the selected radio'
      . ' station.',
  protect_argv => 0,
);

const my $TRUE => 1;    # }}}1

# attributes

# _rtng_interface    {{{1
has '_rtng_interface' => (
  is      => 'ro',
  lazy    => $TRUE,
  isa     => Types::Standard::InstanceOf ['Net::DBus::RemoteObject'],
  default => sub {
    my $self = shift;
    return $self->_rtng_library->interface;
  },
  documentation => 'Interface to DBus Radiotray NG service',
);

# _rtng_library    {{{1
has '_rtng_library' => (
  is            => 'ro',
  isa           => Types::Standard::InstanceOf ['App::Dn::RTNG::Library'],
  default       => sub { return App::Dn::RTNG::Library->new; },
  documentation => 'RTNG library object',
);

# _group    {{{1
has '_group' => (
  is      => 'rw',
  isa     => Types::Standard::Str,
  default => q{},
  doc     => 'Station group selected by user',
);

# _station    {{{1
has '_station' => (
  is      => 'rw',
  isa     => Types::Standard::Str,
  default => q{},
  doc     => 'Station selected by user',
);    # }}}1

# methods

# run()    {{{1
#
# does:   main method
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub run ($self) {

  # select group and station
  $self->_select_station;

  # stop playing station
  if ($self->_rtng_library->player_playing) {
    $self->_rtng_interface->stop;
  }

  # set volume to station default
  $self->_rtng_library->set_volume($self->_station);

  # play selected station
  $self->_rtng_interface->play_station($self->_group, $self->_station);

  return;
}

# _select($title, $prompt, $items)    {{{1
#
# does:   select item from a list
# params: $title  - menu title [scalar string, required]
#         $prompt - menu prompt [scalar string, required]
#         $items  - menu items [arrayref, required, non-empty]
# prints: error message if fails
# return: string (item selected) or FALSE (no item selected)
sub _select ($self, $title, $prompt, $items) {
  return App::Dn::RTNG::Select->new(
    items  => $items,
    prompt => $prompt,
    title  => $title,
  )->run;
}

# _select_station()    {{{1
#
# does:   select station group and station
# params: nil
# prints: error message if fails
# return: string, dies on failure
sub _select_station ($self) {

  my $title  = 'Radiotray NG';
  my @groups = sort $self->_rtng_library->group_names;

  while ($TRUE) {

    # first select station group
    my $prompt = 'Select station group';
    my $group  = $self->_select($title, $prompt, [@groups]);
    if (not $group) { die "No station selected\n"; }
    $self->_group($group);

    # now select station from group
    my @stations =
        sort $self->_rtng_library->group_station_names($group);
    if (not @stations) { die "Group $group has no stations\n"; }
    $prompt = 'Select station';
    my $station = $self->_select($title, $prompt, [@stations]);
    if ($station) {
      $self->_station($station);
      last;
    }
  }

  return;
}    # }}}1

1;

#  NOTE: ignore "BEGIN failed" syntax warnings
# • the script that loaded App::Dn::RTNG::Change did so by adding its
#   directory to @INC
# • App::Dn::RTNG::Library is in the same directory, but the perlcritic
#   static analyser does not know that, hence the error

# POD    {{{1

__END__

=head1 NAME

App::Dn::RTNG::Change - change the S<Radiotray NG> station

=head1 VERSION

This documentation is for C<App::Dn::RTNG::Change> version 0.1.

=head1 SYNOPSIS

    use App::Dn::RTNG::Change;

    App::Dn::RTNG::Change->new_with_options->run;

=head1 DESCRIPTION

The user selects a bookmarked radio station defined in S<Radiotray NG> and
plays it. If S<Radiotray NG> is currently playing a radio station it will stop
it and start the selected radio station.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

None.

=head2 Attributes

None.

=head2 Configuration files

Uses a configuration file with the file name stem 'rtng-play-change' placed in
one of the usual configuration file locations.
(See L<File::ConfigDir> and L<Config::Any> for further details.)

Any of the file formats supported by L<Config::Any> can be used.
Configuration support is limited to default volume set on a per station basis.
There must be a section called 'volume' within which are key:value pairs where
keys are station names and values are corresponding volumes.
The volume values can be any format supported by C<pactl>.

Here is an example configuration file located in
S<< F<$HOME/.config/rtng-play-change.json> >>:

    {
      "volume": {
        "ABC Country": "40%",
        "Country 108": "25%"
      }
    }

=head2 Environment variables

None used.

=head1 SUBROUTINES/METHODS

=head2 run()

The only public method.
It changes the station being played as described in L</DESCRIPTION>.

=head1 DIAGNOSTICS

=head2 org.freedesktop.DBus.Error.ServiceUnknown

The full error is:

    org.freedesktop.DBus.Error.ServiceUnknown:
    The name com.github.radiotray_ng was not provided by any .service files

The commonest cause of this error is that S<Radiotray NG> is not running.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

App::Dn::RTNG::Library, App::Dn::RTNG::Select, App::Dn::RTNG::Stations,
Const::Fast, Moo, MooX::Options, namespace::clean, strictures, Types::Standard,
version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
