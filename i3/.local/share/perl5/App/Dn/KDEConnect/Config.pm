package App::Dn::KDEConnect::Config;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;
use Config::Any;
use Const::Fast;
use File::ConfigDir;
use MooX::HandlesVia;
use Types::Standard;

const my $TRUE => 1;    # }}}1

# attributes

# stem    {{{1
has 'stem' => (
  is            => 'ro',
  isa           => Types::Standard::Str,
  required      => $TRUE,
  documentation => 'Stem of name of configuration file',
);    # }}}1

# methods

# run()    {{{1
#
# does:   extract configuration data from configuration file
# params: nil
# prints: error feedback
# return: arrayref
sub run ($self) {

  # variables
  my $stem = $self->stem;

  # get list of configuration directories
  my @cfg_dirs = File::ConfigDir::config_dirs();
  if (not @cfg_dirs) { die "No configuration directories located\n"; }
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
  if (not @{$stem_matches}) { die "No configuration files located\n"; }

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
  my $data = shift @configs;

  return $data;
}    # }}}1

1;

# POD    {{{1

__END__

=head1 NAME

App::Dn::KDEConnect::Config - get configuration data

=head1 VERSION

This documentation is for C<App::Dn::KDEConnect::Config> version 0.1.

=head1 SYNOPSIS

    use App::Dn::KDEConnect::Config;

    my $conf = App::Dn::KDEConnect::Config->new(stem => 'kedconnect-monitor-data');
    my $data = $conf->run;

=head1 DESCRIPTION

Module used by L<App::Dn::KDEConnect::Monitor> to get configuration data.
See L<App::Dn::KDEConnect::Monitor> for more details.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

=head3 stem

Stem of name of configuration file. String. Required.

=head2 Attributes

None.

=head2 Configuration files

See L<App::Dn::KDEConnect::Monitor> for details.

=head2 Environment variables

None used.

=head1 SUBROUTINES/METHODS

=head2 run()

The only method. It gets configuration data as described in L</DESCRIPTION>.

=head3 Parameters

Nil.

=head3 Prints

Error and warning messages.

=head3 Returns

Arrayref.

=head1 DIAGNOSTICS

=head2 Multiple configuration files located based on stem 'STEM'

=head2 Using: FILEPATH

=head2 Ignoring: FILEPATH(S)

These non-fatal error warning messages are shown when multiple configuration
files are found with the provided name stem.

See C<Config::Any> for more details on what file names are searched for.

=head2 No configuration directories located

This is a non-fatal warning that occurs when no configuration directories are
located. This should never happen on a sane *nix system.

See C<File::ConfigDir> for more details about the target directories.

=head2 No configuration files located

This is a non-fatal warning that occurs when no configuration files having the
provided file name stem are found in common configuration directories.

See L<Config::Any> for more details about the search used.

I<Note:> Subsidiary modules may emit their own warning and error messages.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

Config::Any, Const::Fast, File::ConfigDir, Moo, MooX::HandlesVia,
namespace::clean, strictures, Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
