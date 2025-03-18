package App::Dn::RTNG::Library;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;
use Carp qw(croak);
use Config::Any;
use Const::Fast;
use Desktop::Notify;
use File::ConfigDir;
use App::Dn::RTNG::CommandResult;
use App::Dn::RTNG::Station;
use App::Dn::RTNG::Stations;
use IPC::Cmd;
use JSON::MaybeXS;
use MooX::HandlesVia;
use Net::DBus;
use Types::Standard;

const my $TRUE            => 1;
const my $FALSE           => 0;
const my $CONFFILE_STEM   => 'rtng-play-change';
const my $DEFAULT_SINK    => '@DEFAULT_SINK@';                     ## no critic(RequireInterpolationOfMetachars)
const my $FALLBACK_VOLUME => '20%';
const my $MENU_TITLE      => 'Radiotray NG';
const my $MSG_BAD_STATE   => 'Unable to determine player state';
const my $NOTIFY_ICON =>
    '/usr/share/icons/breeze/apps/22/radiotray-ng-on.svg';
const my $PACTL       => 'pactl';
const my $VAL_PLAYING => 'playing';
const my $VAL_STOPPED => 'stopped';
const my $VAL_STATE   => 'state';
const my $VAL_VOLUME  => 'volume';                                 # }}}1

# attributes

# group_names, group_station_names    {{{1
has '_bookmarked_station_groups' => (
  is  => 'ro',
  isa => Types::Standard::HashRef [
    Types::Standard::InstanceOf ['App::Dn::RTNG::Stations'],
  ],
  lazy    => $TRUE,
  default => sub {
    my $self = shift;

    # get radiotray-ng bookmarks via dbus interface and decode them
    # • produces a list of hashes like:
    #   (
    #     {
    #       'group' => 'Jazz',
    #       'stations' => [
    #         {
    #           'name' => 'Smooth Jazz',
    #           'url' => 'http://smoothjazz.com/jazz_128.pls'
    #         },
    #         ...
    #       ],
    #     },
    #     ...
    #   )
    my $output         = $self->_rtng_interface->get_bookmarks;
    my @bookmarks_data = @{ JSON::MaybeXS::decode_json $output };
    if (not @bookmarks_data) { die "No bookmarked station data extracted\n"; }

    # extract grouped station data
    my %grouped_stations = ();
    for my $bookmarks_group_data (@bookmarks_data) {

      # check all required keys are present
      for my $required_key (qw(group stations)) {
        if (not defined $bookmarks_group_data->{$required_key}) {
          die "Group data is missing required key: $required_key\n";
        }
      }

      # get raw group and station data
      my $group         = $bookmarks_group_data->{'group'};
      my @stations_data = @{ $bookmarks_group_data->{'stations'} };

      # skip special 'root' group which has no stations
      next if $group eq 'root' and not @stations_data;

      # get station names and urls for group
      my $stations = App::Dn::RTNG::Stations->new;
      for my $station_data (@stations_data) {
        my $station_name = $station_data->{'name'};
        my $station_url  = URI->new($station_data->{'url'});
        my $station      = App::Dn::RTNG::Station->new(
          name => $station_name,
          url  => $station_url,
        );
        $stations->add_station($station);
      }

      # save group details
      $grouped_stations{$group} = $stations;
    }

    return {%grouped_stations};
  },
  handles_via => 'Hash',
  handles     => {
    _group_stations => 'get',     # ($name)
    group_names     => 'keys',    # () --> list
  },
  doc => 'Groups with stations',
);

sub group_station_names ($self, $name) {
  return $self->_group_stations($name)->station_names;
}

# _player_attribute    {{{1
has '_player_state' => (
  is      => 'ro',
  isa     => Types::Standard::HashRef [Types::Standard::Any],
  lazy    => $TRUE,
  default => sub {
    my $self          = shift;
    my $output        = $self->_rtng_interface->get_player_state;
    my $data_arrayref = JSON::MaybeXS::decode_json $output;
    return $data_arrayref;
  },
  handles_via   => 'Hash',
  handles       => { _player_attribute => 'get' },
  documentation => 'Radiotray NG player state',
);

# _rtng_interface    {{{1
# • NOTE: unable to trap errors in default subroutine (see note below)
has '_rtng_interface' => (
  is      => 'ro',
  isa     => Types::Standard::InstanceOf ['Net::DBus::RemoteObject'],
  lazy    => $TRUE,
  default => sub {
    my $bus     = Net::DBus->session;
    my $service = $bus->get_service('com.github.radiotray_ng');
    my $rtng    = $service->get_object('/com/github/radiotray_ng');
    return $rtng;
  },
  documentation => 'Interface to DBus Radiotray NG service',
);    # }}}1

# methods

# capture_command_output($cmd)    {{{1
#
# does:   run system command and capture output
# params: $cmd - command to run [arrayref, required]
# prints: nil
# return: App::Dn::RTNG::CommandResult object
sub capture_command_output ($self, $cmd) {

  # assume $cmd is well-formed

  # run command
  my ($succeed, $err, $full_ref, $stdout_ref, $stderr_ref) =
      IPC::Cmd::run(command => $cmd);

  # process output
  # - err: has trailing newline
  # - err: prevent undef value as this fails type constraint
  if   (defined $err) { chomp $err; }
  else                { $err = q{}; }

  # - full, stdout and stderr: appears that for at least some commands
  #   all output lines are put into a single string, separated with
  #   embedded newlines, which is then put into a single element list
  #   which is made into an array reference; these are unpacked below
  my @full;
  foreach my $chunk (@{$full_ref}) {
    chomp $chunk;
    my @lines = split /\n/xsm, $chunk;
    push @full, @lines;
  }
  my @stdout;
  foreach my $chunk (@{$stdout_ref}) {
    chomp $chunk;
    my @lines = split /\n/xsm, $chunk;
    push @stdout, @lines;
  }
  my @stderr;
  foreach my $chunk (@{$stderr_ref}) {
    chomp $chunk;
    my @lines = split /\n/xsm, $chunk;
    push @stderr, @lines;
  }

  # return results as an object
  return App::Dn::RTNG::CommandResult->new(
    success      => $succeed,
    error        => $err,
    full_output  => [@full],
    standard_out => [@stdout],
    standard_err => [@stderr],
  );
}

# config($key, [$section])    {{{1
#
# does:   extract value from configuration file
# params: $key     - config value key [string, required]
#         $section - config file section [string, optional]
# prints: feedback
# return: string (success) or undef (failure)
sub config ($self, $key, $section = undef) {

  # variables
  my $stem = $CONFFILE_STEM;
  my $value;

  # get list of configuration directories
  my @cfg_dirs = File::ConfigDir::config_dirs();
  if (not @cfg_dirs) {
    warn "No configuration directories located\n";
    return $value;
  }
  my @stems;
  for my $dir (@cfg_dirs) {
    push @stems, "$dir/$stem", "$dir/$stem/$stem";
  }

  # get config data
  # - Config::Any returns a data structure like:
  # [
  #   { '/home/david/rtng.json' => { $config_data_hashref } },
  #   { '/home/david/.config/rtng.ini' => { $config_data_hashref } }
  # ]
  my $stem_matches =
      Config::Any->load_stems({ stems => [@stems], use_ext => $TRUE });
  if (not @{$stem_matches}) {
    warn "No configuration files located\n";
    return $value;
  }

  # if multiple files found, use first
  my (@config_fps, @configs);
  for my $stem_match (@{$stem_matches}) {
    my ($fp, $config_data) = %{$stem_match};
    push @config_fps, $fp;
    push @configs,    $config_data;
  }
  my $config_fp = shift @config_fps;
  if (@config_fps) {
    warn "Multiple configuration files located based on stem '$stem'\n";
    warn "Using: $config_fp\n";
    warn "Ignoring:\n";
    for my $fp (@config_fps) {
      warn "- $fp\n";
    }
  }
  my $config = shift @configs;

  # extract config value
  if   ($section) { $value = $config->{$section}->{$key}; }
  else            { $value = $config->{$key}; }

  return $value;
}

# interface()    {{{1
#
# does:   provide object encapsulating the "com.github.radiotray_ng" service
# params: nil
# prints: error feedback
# return: an object encapsulating the "com.github.radiotray_ng" service
#         the object is of class "Net::DBus::RemoteObject" .
sub interface ($self) {
  return $self->_rtng_interface;
}

# notify($msg)    {{{1
#
# does:   display a message string as a system notification
# params: $msg - message to display [string, required]
# prints: error feedback
# return: n/a, dies on failure
sub notify ($self, $msg) {
  my %opts = (summary => $MENU_TITLE, body => $msg, timeout => '5000');
  if (-e $NOTIFY_ICON) { $opts{'app_icon'} = $NOTIFY_ICON; }
  my $notify_factory = Desktop::Notify->new;
  my $notification   = $notify_factory->create(%opts);
  $notification->show;
  return;
}

# player_artist()    {{{1
#
# does:   return playing or last played artist name
# params: nil
# prints: error feedback
# return: string
sub player_artist ($self) {
  return $self->_player_attribute('artist');
}

# player_playing()    {{{1
#
# does:   determine whether radiotray-ng player is currently playing
# params: nil
# prints: error feedback
# return: boolean
sub player_playing ($self) {
  my $player_state = $self->_player_attribute($VAL_STATE);
  my $playing;
  if ($player_state eq $VAL_PLAYING) { $playing = $TRUE; }
  if ($player_state eq $VAL_STOPPED) { $playing = $FALSE; }
  if (not defined $playing) {
    croak $MSG_BAD_STATE;
  }
  return $playing;
}

# player_station()    {{{1
#
# does:   return playing or last played station name
# params: nil
# prints: error feedback
# return: string
sub player_station ($self) {
  return $self->_player_state->{'station'};
}

# player_stopped()    {{{1
#
# does:   determine whether radiotray-ng player is currently stopped
# params: nil
# prints: error feedback
# return: boolean
sub player_stopped ($self) {
  my $player_state = $self->_player_attribute($VAL_STATE);
  my $stopped;
  if ($player_state eq $VAL_PLAYING) { $stopped = $FALSE; }
  if ($player_state eq $VAL_STOPPED) { $stopped = $TRUE; }
  if (not defined $stopped) {
    croak $MSG_BAD_STATE;
  }
  return $stopped;
}

# player_title()    {{{1
#
# does:   return playing or last played track title
# params: nil
# prints: error feedback
# return: string
sub player_title ($self) {
  return $self->_player_attribute('title');
}

# run_command($cmd)    {{{1

# does:   run a shell command
# params: $cmd - shell command [arrayref, required]
# prints: error feedback
# return: n/a, dies if command exits with an error status
sub run_command($self, $cmd) {

  # process arguments
  # - $cmd
  if (not(defined $cmd)) { croak 'No command provided'; }
  my $arg_type = ref $cmd;
  if ($arg_type ne 'ARRAY') { croak "Expected ARRAY, got: $arg_type"; }
  my @cmd_args = @{$cmd};
  if (not @cmd_args) { croak 'No command arguments provided'; }

  # run command
  my ($succeed, $err, $full, $stdout, $stderr) =
      IPC::Cmd::run(command => $cmd);

  # provide final feedback
  # - errors displayed during command execution
  if (not $succeed) {
    if (not $err) { warn "No error message available\n"; }
    croak 'Stopping execution due to error';
  }

  # return
  return $succeed;
}

# set_volume()    {{{1
#
# does:   set system volume
# params: $station - name of station [string, required]
# prints: warning and error messages
# return: n/a
sub set_volume ($self, $station) {

  # check for required tools
  IPC::Cmd::can_run($PACTL) or die "Cannot run without '$PACTL'\n";

  # get volume
  my $volume;

  # • first, look for configured volume for given station
  if ($station) {
    $volume = $self->config($station, $VAL_VOLUME);
  }

  # • if that fails, try for configured default
  if (not $volume) {
    if ($station) {
      warn "No volume configured for station '$station'\n";
    }
    $volume = $self->config($VAL_VOLUME, 'default');
  }

  # • if that also fails, use fallback volume
  if (not $volume) {
    warn "No default volume configured\n";
    $volume = $FALLBACK_VOLUME;
  }

  # set volume
  my $cmd_unmute = [ $PACTL, 'set-sink-mute', $DEFAULT_SINK, 'false' ];
  $self->run_command($cmd_unmute);
  my $cmd_set_vol = [ $PACTL, 'set-sink-volume', $DEFAULT_SINK, $volume ];
  $self->run_command($cmd_set_vol);

  return;
}

# status_message()    {{{1
#
# does:   construct status message
# params: nil
# prints: feedback
# return: scalar string
sub status_message ($self) {

  # variables
  my $playing = $self->player_playing;
  my $station = $self->player_station;
  my $title   = $self->player_title;
  my $artist  = $self->player_artist;
  my $msg;

  # assemble status message
  if ($playing) {
    if (not $station) {
      $msg = sprintf 'Streaming unknown station';
    }
    elsif ((not $title) or (not $artist)) {
      $msg = sprintf "Streaming: %s\nTrack details unavailable", $station;
    }
    else {
      $msg = sprintf "Streaming: %s\nPlaying: %s (%s)", $station,
          $title, $artist;
    }
  }
  else {    # stopped
    if (not $station) {
      $msg = 'Currently stopped';
    }
    else {
      $msg = sprintf "Currently stopped\nLast station: %s", $station;
    }
  }

  return $msg;
}    # }}}1

1;

#  NOTE: unable to trap errors in generating rtng interface object
# • the error caused when radiotray-ng is not running is:
#       org.freedesktop.DBus.Error.ServiceUnknown: \
#       The name com.github.radiotray_ng was not provided by any .service files
# • this error is generated *within* the Moo calling code and occurs before
#   control is returned to the interface construction script,
#   so it cannot be trapped

#  NOTE: ignore "Can't locate App::Dn::RTNG::*.pm" syntax warnings
# • the script that loaded App::Dn::RTNG::Library did so by adding its
#   directory to @INC
# • The other App::Dn::RTNG::* modules are in the same directory, but the
#   perlcritic static analyser does not know that, hence the error

# POD    {{{1

__END__

=head1 NAME

App::Dn::RTNG::Library - common subroutines used by Radiotray NG controller scripts

=head1 VERSION

This documentation is for C<App::Dn::RTNG::Library> version 0.1.

=head1 SYNOPSIS

    use App::Dn::RTNG::Library;

    my $lib = App::Dn::RTNG::Library->new;

=head1 DESCRIPTION

Common subs used by Radiotray NG controller scripts.

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

=head2 capture_command_output($cmd)

Run system command and capture output.

=head3 Parameters

=over

=item $cmd

Command to run. Arrayref. Required.

=back

=head3 Prints

Nil.

=head3 Returns

Dn::Common::CommandResult object.

=head3 Note

The returned object can provide stdout output, stderr output and full output
(stdout and stderr combined as initially output). In each case, the output is
provided as a list, with each list element being a line of original output.

=head2 config($key, [$section])

Extract a configuration value from a configuration file.
All the usual configuration directories are searched for configuration files
whose names contain the stem "rtng-play-change".
If multiple matching configuration files are found, the first is used while
the others are ignored.
(See L<File::ConfigDir> and L<Config::Any> for further details.)

If multiple configuration files are located, the first found is used.
The user is warned which configuration file is used and which are ignored.

Configuration files with and without sections are supported.
Provide a C<section> value only if the configuration file has sections,
that is, there is no need to use a dummy section name if sections are not used.

=head3 Parameters

=over

=item $key

Configuration file key whose value is extracted. Scalar string. Required.

=item $section

Configuration file section in which to find desired key value. Scalar string.
Optional.

=back

=head3 Prints

Warning and error feedback.

=head3 Returns

Scalar configuration value or boolean false.

=head2 group_names()

Provides the names of all bookmarked radio station groups.

=head3 Parameters

Nil.

=head3 Prints

Nil.

=head3 Returns

List of group names.

=head2 group_station_names($name)

Provides names of bookmarked radio stations in a specified bookmark group.

=head3 Parameters

Nil.

=head3 Prints

Nil.

=head3 Returns

List of station names.

=head2 interface()

Provides an object encapsulating the "com.github.radiotray_ng" service.

=head3 Parameters

Nil.

=head3 Prints

Error feedback.

=head3 Returns

An object encapsulating the "com.github.radiotray_ng" service.
The object is of class "Net::DBus::RemoteObject".

=head2 notify($msg)

Display a message string as a system notification.

=head3 Parameters

=over

=item $msg

The message to display. Scalar string. Required.

=back

=head3 Prints

Error feedback.

=head3 Returns

N/A. Dies on failure.

=head2 player_artist()

Get the playing or last played artist name.

=head3 Parameters

Nil.

=head3 Prints

Error feedback.

=head3 Returns

String.

=head2 player_playing()

Determine whether the Radiotray NG player is currently playing.

=head3 Parameters

Nil.

=head3 Prints

Error feedback.

=head3 Returns

Boolean.

=head2 player_station()

Get the playing or last played station name.

=head3 Parameters

Nil.

=head3 Prints

Error feedback.

=head3 Returns

String.

=head2 player_stopped()

Determine whether the Radiotray NG player is currently stopped.

=head3 Parameters

Nil.

=head3 Printsl

Error feedback.

=head3 Returns

Boolean.

=head2 player_title()

Get the playing or last played track title.

=head3 Parameters

Nil.

=head3 Prints

Error feedback.

=head3 Returns

String.

=head2 run_command($cmd)

Run a shell command.

=head3 Parameters

=over

=item $cmd

Shell command. Arrayref. Required.

=back

=head3 Prints

Error feedback.

=head3 Returns

N/A. Dies if command exits with an error status.

=head2 set_volume()

Set system volume using C<pactl>.

=head3 Parameters

=over

=item $station

Name of station. String. Required.

=back

=head3 Prints

Warning and error messages.

=head3 Returns

N/A.

=head2 status_message()

Construct a message reporting the current state of the S<Radiotray NG> player.

=head3 Parameters

Nil.

=head3 Prints

Nil.

=head3 Returns

Scalar string.

=head1 DIAGNOSTICS

=head2 Cannot run without 'pactl'

This error occurs if the C<set_volume> function is called and C<pactl> is not
available on the system.

=head2 Multiple configuration files located based on stem 'STEM'

=head2 Using: FILEPATH

=head2 Ignoring: FILEPATH(S)

These non-fatal error warning messages are shown when multiple configuration
files are found with the name stem "rtng-play-change".
See C<Config::Any> for more details on what file names are searched for.

=head2 No command provided

=head2 Command is not an arrayref

=head2 No command arguments provided

These errors occur if the shell command provided to be executed is empty or of
the wrong data type.

=head2 No configuration directories located

This is a non-fatal warning that occurs when no configuration directories are
located. This should never happen on a sane *nix system.
See C<File::ConfigDir> for more details about the target directories.

=head2 No configuration files located

This is a non-fatal warning that occurs when no configuration files having the
name stem "rtng-play-change" are found in common configuration directories.
See L<Config::Any> for more details about the search used.

=head2 No default volume configured

This warning is issued if the configuration file has no station-independent
default volume specified. Note that the C<config> method only looks for a
station-independent default volume if it is unable to find a station-specific
default volume.

=head2 No status data extracted

This fatal error occurs if an attempt to extract player status data from
Radiotray NG failed.

=head2 No volume configured for station 'STATION'

The non-fatal warning is displayed if the configuration file used does not
specify a default volume for the specified station.

=head2 org.freedesktop.DBus.Error.ServiceUnknown

The full error is:

    org.freedesktop.DBus.Error.ServiceUnknown:
    The name com.github.radiotray_ng was not provided by any .service files

The commonest cause of this error is that Radiotray NG is not running.

=head2 Stopping execution due to error

=head2 No error message available

These fatal error messages may be displayed when a shell command exits with an
error status.

=head2 Unable to determine player state

Occurs when the script is unable to determine from Radiotray NG player state
data whether it is currently playing or stopped.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

App::Dn::RTNG::CommandResult, App::Dn::RTNG::Station, App::Dn::RTNG::Stations,
Carp, Config::Any, Const::Fast, Desktop::Notify, File::ConfigDir, IPC::Cmd,
JSON::MaybeXS, Moo, MooX::HandlesVia, namespace::clean, Net::DBus, strictures,
Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
