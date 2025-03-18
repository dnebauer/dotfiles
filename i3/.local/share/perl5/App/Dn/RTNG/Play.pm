package App::Dn::RTNG::Play;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean -except => [ '_options_data', '_options_config' ];
use App::Dn::RTNG::Library;    # NOTE: ignore syntax warning (see note below)
use Const::Fast;
use Types::Standard;
use MooX::Options (
  authors     => 'David Nebauer <david at nebauer dot org>',
  description => 'Uses the Radiotray NG DBus interface to play the last'
      . ' station if none is currently playing, or pause the current'
      . " station if one is currently playing.\n\n"
      . 'Sets the volume to the configured station default volume'
      . ' using C<pactl>.',
  protect_argv => 0,
);

const my $TRUE => 1;

# }}}1

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
);    # }}}1

# methods

# run()    {{{1
#
# does:   main method
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub run ($self) {

  # set system volume if starting player
  if ($self->_rtng_library->player_stopped) {
    my $station = $self->_rtng_library->player_station;
    $self->_rtng_library->set_volume($station);
  }

  # play/pause using radiotry-ng dbus interface
  $self->_rtng_interface->play;

  return;
}    # }}}1

1;

#  NOTE: ignore "BEGIN failed" syntax warnings
# • the script that loaded App::Dn::RTNG::Play did so by adding its
#   directory to @INC
# • App::Dn::RTNG::Library is in the same directory, but the perlcritic
#   static analyser does not know that, hence the error

# POD    {{{1

__END__

=head1 NAME

App::Dn::RTNG::Play - play or pause a S<Radiotray NG> station

=head1 VERSION

This documentation is for C<App::Dn::RTNG::Play> version 0.1.

=head1 SYNOPSIS

    use App::Dn::RTNG::Play;

    App::Dn::RTNG::Play->new_with_options->run;

=head1 DESCRIPTION

Uses the S<Radiotray NG> DBus interface to:

=over

=item *

play the last-played station if the player is currently stopped

=item *

stop the player if it is currently playing.

=back

When commencing play the script tries to set the default volume for the
station to be streamed. This is done by examining configuration file(s).
See L</Configuration files> for more details.

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

The only public method. It uses the S<Radiotray NG> DBus interface to start the
player if it is stopped, or stop the player if it is playing.

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

App::Dn::RTNG::Library, Const::Fast, namespace::clean, Moo, MooX::Options, strictures, Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
