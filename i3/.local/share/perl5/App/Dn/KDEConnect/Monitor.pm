package App::Dn::KDEConnect::Monitor;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean -except => [ '_options_data', '_options_config' ];
use App::Dn::KDEConnect::CommandResult
    ;    # NOTE: ignore syntax warning (see note below)
use App::Dn::KDEConnect::Config;
use App::Dn::KDEConnect::Device;
use Carp qw(croak);
use Const::Fast;
use Desktop::Notify;
use IPC::Cmd;
use MooX::HandlesVia;
use Types::Standard;
use MooX::Options (
  authors     => 'David Nebauer <david at nebauer dot org>',
  description => 'Periodically use kdeconnect-cli to attempt to'
      . ' connect unconnected devices.',
  protect_argv => 0,
);

const my $TRUE           => 1;
const my $FALSE          => 0;
const my $CHECK_INTERVAL => 600;    # 10 minutes (10 * 60 seconds)
const my $CONFIG_STEM    => 'kdeconnect-monitor-data';
const my $ICON_NOTIFY =>
    '/usr/share/icons/hicolor/scalable/apps/kdeconnect.svg';
const my $KDECONNECT         => 'kdeconnect-cli';
const my $MENU_TITLE         => 'KDEConnect Monitor';
const my $FAIL_COUNT_TRIGGER => 3;
const my $OPT_ID_NAME_ONLY   => '--id-name-only';
const my $OPT_LIST_AVAILABLE => '--list-available';
const my $OPT_LIST_DEVICES   => '--list-devices';
const my $OPT_REFRESH        => '--refresh';
const my $SECT_DEVICES       => 'devices';
const my $STR_COLON_NEWLINE  => ":\n";                  # }}}1

# attributes

# _devices(), _has_devices()    {{{1
has '_devices_array' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf ['App::Dn::KDEConnect::Device'],
  ],
  lazy    => $TRUE,
  default => sub {
    my $self = shift;
    my $data = App::Dn::KDEConnect::Config->new(stem => $CONFIG_STEM)->run;
    my $ref  = ref $data;
    if (not $ref) { die "Expected hashref config data, got a non-ref\n"; }
    if ($ref ne 'HASH') {
      die "Expected hashref config data, got a $ref ref\n";
    }
    my %data_hash = %{$data};
    if (not exists $data_hash{$SECT_DEVICES}) {
      die "No 'devices' section found in configuration file\n";
    }
    my %devices = %{ $data_hash{$SECT_DEVICES} };
    if (not keys %devices) {
      die "No device data found in configuration files\n";
    }
    my @device_objects;
    for my $name (keys %devices) {
      my $id            = $devices{$name};
      my $device_object = App::Dn::KDEConnect::Device->new(
        name          => $name,
        id            => $id,
        checks_failed => $FAIL_COUNT_TRIGGER
        ,    # force notification on startup if not connected
      );
      push @device_objects, $device_object;
    }
    return [@device_objects];
  },
  handles_via => 'Array',
  handles     => {
    _devices     => 'elements',    # --> @devices
    _has_devices => 'count',       # --> bool
  },
  doc => 'Devices to be connected',
);                                 # }}}1

# methods

# run()    {{{1
#
# does:   main method
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub run ($self) {

  # get connectable devices
  my @devices = $self->_devices;

  # try to ensure all connectable devices are connected
  $self->_refresh_connections;

  # perpetual loop
  while ($TRUE) {

    # get current state of device connections
    my %connected = %{ $self->_connected_devices };

    # cycle through each device
    my $need_refresh = $FALSE;

    for my $device (@devices) {

      # are we skipping?
      my $device_checks_to_skip = $device->checks_to_skip;
      if ($device_checks_to_skip) {
        my $checks_skipped = $device->checks_skipped;
        if ($checks_skipped < $device_checks_to_skip) {
          $device->increment_checks_skipped;
          next;    # yes, we are skipping
        }
        else {
          $device->checks_skipped(0);
        }
      }

      # ok, not skipping
      my $device_name      = $device->name;
      my $device_label     = sprintf '%s (%s)', $device_name, $device->id;
      my $device_connected = $device->connected;

      # if device currently connected...
      if ($connected{$device_name}) {
        $device->checks_failed(0);

        # ... and recorded as connected, then
        # nothing to do
        if ($device_connected) {
          next;
        }

        # ... but recorded as not connected, then
        # assume it was just connected
        else {
          $device->connected($TRUE);
          $self->_notify("Connected device: $device_label");
        }
      }

      # if device currently not connected...
      else {
        $need_refresh = $TRUE;

        # ... but recorded as connected, then
        # assume it was just disconnected
        if ($device_connected) {
          $device->connected($FALSE);
          $self->_notify("Device $device_label has disconnected");
        }

        # ... and recorded as not connected, then
        # is persistently not connected
        else {

          # display message after 3 failed checks
          my $checks_failed = $device->checks_failed;
          if ($checks_failed == $FAIL_COUNT_TRIGGER) {
            $self->_notify("Unable to connect device: $device_label");
            $device->checks_failed(0);
          }
          $device->increment_checks_failed;

          # increase number of skipped checks
          $device->increase_checks_to_skip;
        }
      }
    }    # for my $device (@devices)

    # refresh connections if needed
    if ($need_refresh) {
      $self->_refresh_connections;
    }

    # pause for 10 minutes
    sleep $CHECK_INTERVAL;
  }

  return;
}

# _capture_command_output($cmd)    {{{1
#
# does:   run system command and capture output
# params: $cmd - command to run [arrayref, required]
# prints: nil
# return: App::Dn::KDEConnect::CommandResult object
sub _capture_command_output ($self, $cmd) {

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
  return App::Dn::KDEConnect::CommandResult->new(
    success      => $succeed,
    error        => $err,
    full_output  => [@full],
    standard_out => [@stdout],
    standard_err => [@stderr],
  );
}

# _connected_devices()    {{{1
#
# does:   get hash of connected devices
# params: nil
# prints: error messages
# return: hashref, { name => id }
sub _connected_devices ($self) {
  my $cmd    = [ $KDECONNECT, $OPT_LIST_DEVICES, $OPT_ID_NAME_ONLY ];
  my $result = $self->_capture_command_output($cmd);
  if (not $result->success) {
    my $msg = 'kdeconnect-cli list devices command failed';
    if ($result->error) { $msg .= $STR_COLON_NEWLINE . $result->error; }
    die "$msg\n";
  }
  my %devices;
  for my $line ($result->stdout) {
    if ($line =~ /\A(\S+)\s+(.*)\z/xsm) {
      $devices{$2} = $1;
    }
    else {
      croak "Incomprehensible data from kdeconnect-cli:\n'$line'";
    }
  }
  return {%devices};
}

# _notify($msg)    {{{1
#
# does:   display a message string as a system notification
# params: $msg - message to display [string, required]
# prints: error feedback
# return: n/a, dies on failure
sub _notify ($self, $msg) {
  my %opts = (summary => $MENU_TITLE, body => $msg, timeout => '5000');
  if (-e $ICON_NOTIFY) { $opts{'app_icon'} = $ICON_NOTIFY; }
  my $notify_factory = Desktop::Notify->new;
  my $notification   = $notify_factory->create(%opts);
  $notification->show;
  return;
}

# _refresh_connections()    {{{1
#
# does:   attempt to refresh device connections
# params: nil
# prints: error messages
# return: n/a, dies on failure
sub _refresh_connections ($self) {

  # run 'kdeconnect-cli --refresh'
  my $cmd    = [ $KDECONNECT, $OPT_REFRESH ];
  my $result = $self->_capture_command_output($cmd);
  if (not $result->success) {
    my $msg = 'kdeconnect-cli refresh command failed';
    if ($result->error) { $msg .= $STR_COLON_NEWLINE . $result->error; }
    die "$msg\n";
  }

  # run 'kdeconnect-cli --list-available'
  $cmd    = [ $KDECONNECT, $OPT_LIST_AVAILABLE ];
  $result = $self->_capture_command_output($cmd);
  if (not $result->success) {
    my $msg = 'kdeconnect-cli list available devices command failed';
    if ($result->error) { $msg .= $STR_COLON_NEWLINE . $result->error; }
    die "$msg\n";
  }

  return;
}

1;

#  NOTE: ignore "BEGIN failed" syntax warnings
# • the script that loaded App::Dn::KDEConnect::Monitor did so by adding its
#   directory to @INC
# • App::Dn::Clipboard::* are in the same directory, but the perlcritic
#   static analyser does not know that, hence the error

# POD    {{{1

__END__

=head1 NAME

App::Dn::KDEConnect::Monitor - monitor connected devices using kdeconnect

=head1 VERSION

This documentation applies to L<App::Dn::KDEConnect::Monitor> version 0.1.

=head1 SYNOPSIS

    use App::Dn::KDEConnect::Monitor;
    App::Dn::KDEConnect::Monitor->new_with_options->run;

=head1 DESCRIPTION

Periodically uses C<kdeconnect-cli> to try and connect unconnected devices.
The user is notified if S<3 consecutive> attempts to connect a device fail,
following which the check interval lengthens with each failed connection
attempt until the interval is at least S<1.5 hours.>

Devices are specified in a configuration file.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

None.

=head2 Configuration files

Uses a configuration file with the file name stem 'kdeconnect-monitor-data'
placed in one of the usual configuration file locations.
(See L<File::ConfigDir> and L<Config::Any> for further details.)

Any of the file formats supported by L<Config::Any> can be used.
There must be a section called 'devices' within which are key:value pairs where
keys are device names and values are corresponding ids.
Device names and ids can be obtained using C<kdeconnect-cli> once they are
connected.

Here is an example configuration file located in
S<< F<$HOME/.config/kdeconnect-monitor-data.json> >>:

    {
      "devices": {
        "Galaxy S10e": "61ed761205f01d63"
      }
    }

=head2 Environment variables

None used.

=head1 SUBROUTINES/METHODS

=head2 run()

The only public method. This method enables the monitoring of connectable
devices as described in L</DESCRIPTION>.

=head1 DIAGNOSTICS

=head2 Expected hashref config data, got a non-ref

=head2 Expected hashref config data, got a REF_TYPE ref

These fatal errors occur when the retrieved configuration data is in an
unexpected format. See L<App::Dn::KDEConnect::Config> for more details.

=head2 No 'devices' section found in configuration file

=head2 No device data found in configuration files

These fatal errors occur when the configuration data contains no defined
devices.

=head2 kdeconnect-cli list devices command failed: ERROR_MESSAGE

=head2 kdeconnect-cli refresh command failed: ERROR_MESSAGE

=head2 kdeconnect-cli list available devices command failed: ERROR_MESSAGE

These fatal errors occurs when C<kdeconnect-cli> exits with an error status.

=head2 Incomprehensible data from kdeconnect-cli: 'LINE'

This fatal error occurs when a line of output from C<kdeconnect-cli> cannot be
parsed.

I<Note:> Subsidiary modules may emit their own warning and error messages.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

App::Dn::KDEConnect::CommandResult, App::Dn::KDEConnect::Config,
App::Dn::KDEConnect::Device, Carp, Const::Fast, Desktop::Notify, IPC::Cmd, Moo,
MooX::HandlesVia, MooX::Options, Types::Standard, namespace::clean, strictures,
version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
