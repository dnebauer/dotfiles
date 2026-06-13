package App::My::PandocUpdateFilters::Repository;

use Moo;    # {{{1
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;

# WARN: ignore syntax warnings for "BEGIN failed" and "Can't locate App::..."
# • The script that loaded this module did so by adding its directory
#   to @INC with File::FindLib
# • The App::... modules loaded below are in the same directory, but the
#   perlcritic static analyser does not know that, and hence the error
use App::My::PandocUpdateFilters::FilepathMapping;
use App::My::PandocUpdateFilters::Substitution;
use Const::Fast;
use English;
use MooX::HandlesVia;
use MooX::Options (
  authors      => 'David Nebauer <david at nebauer dot org>',
  description  => 'Model an online code repository',
  protect_argv => 0,
);
use Path::Tiny;
use Types::Standard;
use URI;

with qw(Role::Utils::Dn);

const my $TRUE          => 1;
const my $FALSE         => 0;
const my $MOD_PATH_TINY => 'Path::Tiny';    # }}}1

# attributes

# download_dir    {{{1
has 'download_dir' => (
  is       => 'ro',
  isa      => Types::Standard::InstanceOf [$MOD_PATH_TINY],
  coerce   => $TRUE,
  required => $TRUE,
  doc      => 'Temporary directory repo files are downloaded to',
);

# name    {{{1
has 'name' => (
  is       => 'ro',
  isa      => Types::Standard::Str,
  required => $TRUE,
  doc      => 'Project name for repository',
);

# description    {{{1
has 'description' => (
  is       => 'ro',
  isa      => Types::Standard::Str,
  required => $TRUE,
  doc      => 'Description of repository',
);

# download_url    {{{1
has 'download_url' => (
  is       => 'ro',
  isa      => Types::Standard::InstanceOf ['URI'],
  coerce   => $TRUE,
  required => $TRUE,
  doc      => 'URL for downloading of remote repository',
);

# asset_type    {{{1
has 'asset_type' => (
  is  => 'ro',
  isa => Types::Standard::Maybe [
    Types::Standard::Enum [ \$TRUE, qw(targz) ]
  ],
  required => $TRUE,
  coerce   => $TRUE,
  doc      => 'Asset release file type (guides extraction command)',
);

# obtain_method    {{{1
has 'obtain_method' => (
  is  => 'ro',
  isa => Types::Standard::Enum [ \$TRUE,
    qw(git-clone-repository download-release-asset) ],
  required => $TRUE,
  coerce   => $TRUE,
  doc      => 'Download method for repo',
);

# release_path_extraction_regex    {{{1
has 'release_path_extraction_regex' => (
  is       => 'ro',
  isa      => Types::Standard::Maybe [Types::Standard::RegexpRef],
  required => $TRUE,
  default  => undef,
  doc      => 'Regex for extracting release path from filepath',
);

# filepath_mappings    {{{1
has 'filepath_mappings' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf [
      'App::My::PandocUpdateFilters::FilepathMapping'],
  ],
  required => $TRUE,
  doc      => 'Array of filepath mapping objects',
);

# delete_paths    {{{1
has 'delete_paths' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf [$MOD_PATH_TINY],
  ],
  required => $TRUE,
  doc      => 'Repository files and directories to delete',
);

# ignore_files, load_ignore_files, unload_ignore_files    {{{1
has 'ignore_files' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf [$MOD_PATH_TINY],
  ],
  required => $TRUE,
  doc      => 'Repository files to ignore',
);

# substitutions    {{{1
has 'substitutions' => (
  is  => 'ro',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf [
      'App::My::PandocUpdateFilters::Substitution'],
  ],
  required => $TRUE,
  doc      => 'String substitutions for repo files',
);

# obtained_files    {{{1
# • not expected to be provided at instantiation
has 'obtained_files' => (
  is  => 'lazy',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf [$MOD_PATH_TINY],
  ],
  doc => 'Files obtained from repo',
);

sub _build_obtained_files($self) {    ## no critic (ProhibitUnusedPrivateSubroutines)
  my $download_dir = $self->download_dir;
  my @fps          = $self->file_list_recursively($download_dir);
  my @obtained     = map { Path::Tiny::path($_) } @fps;
  return [@obtained];
}

# updated_files    {{{1
# • not expected to be provided at instantiation
has 'updated_files' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf [
      'App::My::PandocUpdateFilters::FilepathMapping'],    ## no critic (ProhibitDuplicateLiteral)
  ],
  required => $TRUE,
  default  => sub { [] },
  doc      => 'Repo files to update in stow package',
);    # }}}1

1;

# POD    {{{1
__END__

=encoding utf8

=head1 NAME

App::My::PandocUpdateFilters::Repository - update a local lesspipe.sh installation

=head1 VERSION

This documentation is for App::My::PandocUpdateFilters::Repository version 0.1.

=head1 SYNOPSIS

    use strictures 2;
    use 5.006;
    use 5.038_001;
    use namespace::clean;
    use App::My::PandocUpdateFilters::Repository;
    use Const::Fast;
    use Types::Standard;

    const my $TRUE => 1;

    has '_repos_array' => (
      is  => 'rw',
      isa => Types::Standard::ArrayRef [
        Types::Standard::InstanceOf [
          'App::My::PandocUpdateFilters::Repository'],
      ],
      required    => $TRUE,
      default     => sub { [] },
      handles_via => 'Array',
      handles     => {
        _repos    => 'elements',
        _add_repo => 'push',
      },
      doc => 'Array of repository objects',
    );

=head1 DESCRIPTION

This module models the download of an online (github) repository to a temporary
directory where some of its contents are copied to a local stow package.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Options

None.

=head2 Properties/attributes

=head3 download_dir

Temporary directory repo files are downloaded to.

Required. Read-only. L<Path::Tiny> instance.

=head3 name

Project name for repository. Required. Read-only. String.

=head3 description

Human-readable description of repository.

Required. Read-only. String.

=head3 download_url

URL for downloading of remote repository. Could be used for a C<git clone>
command or could be the current/latest asset archive file.

Required. Read-only. L<URI> instance.

=head3 asset_type

Asset release file type. This value determines the command used to extract the
contents of the release asset archive file.

Required if <obtain_method> is "download-release-asset", otherwise optional.
Read-only. String. Default: undef. Allowed value: 'targz'.

=head3 obtain_method

Download method for repository.

Required. Read-only. String.
Allowed values: 'git-clone-repository', 'download-release-asset'.

=head3 release_path_extraction_regex

Regular expression for extracting the release path from a filepath.

Required if <obtain_method> is "download-release-asset", otherwise optional.
Read-only. String. Default: undef.

=head3 filepath_mappings

All mappings between downloaded repository files and stow package filters
directory files.

Required. Read-write. Array of
L<App::My::PandocUpdateFilters::FilepathMapping> instances.

=head3 delete_paths

Repository files and directories to delete immediately after downloading and,
if necessary, extracting.

Required. Read-write. Array of L<Path::Tiny> instances.

=head3 ignore_files

Repository files to ignore.

Required. Read-write. Array of L<Path::Tiny> instances.

=head3 substitutions

String substitutions for repository files.

Required. Read-only. Array of
L<App::My::PandocUpdateFilters::Substitution> instances.

=head3 obtained_files

Files obtained from repository.

Optional, not expected to be provided at instantiation.
Read-only: file list created on first read. Array of L<Path::Tiny> instances.

=head3 updated_files

Subset of <obtained_files> that represent updated files, that is, files that
are new or changed since last update. Optional, not expected to be provided at
instantiation. Read-write. Array of
L<App::My::PandocUpdateFilters::FilepathMapping> instances. Default: [].

=head2 Configuration file

None used.

=head2 Environment variables

None used.

=head1 SUBROUTINES/METHODS

=head2 run()

Main module method. Performs the tasks described in the L<DESCRIPTION> section.

=head3 Params

None.

=head3 Prints

Feedback and messages as required.

=head3 Returns

N/A. Dies on failure.

=head1 DIAGNOSTICS

=head2 Expected config data HASH, got: VAR_TYPE

=head2 Expected KEY value to be TYPE, got TYPE

=head2 Expected KEY->SUBKEY value to be TYPE, got TYPE

=head2 Invalid primary key KEY

=head2 Invalid key KEY->SUBKEY

=head2 No config file key: KEY

=head2 No config file key: KEY->SUBKEY

=head2 Expected array with 1 element, got NUM

=head2 Expected TYPE, got: TYPE

=head2 No config section named NAME

=head2 No key named NAME in section NAME

These errors occur when the configuration file is being read and the data is
in an unexpected format.

=head2 Copying current project files into stow package ... ERROR

This occurs when a file copy fails. The most likely cause is that the target
stow package subdirectory does not exist.

=head2 INSTALL_DIR not set

=head2 STOW_ROOT not set

=head2 STOW_PKG not set

These errors occur if values for any of these placeholders are not set. These
errors should not occur as earlier errors should have halted processing before
these errors are generated.

=head2 No configuration files located

Occurs if none of the combinations of candidate configuration directories,
file stem, and suffixes result in a locatable filepath.

=head2 No stem name provided

Occurs if no configuration file base name is available.

=head2 Slurp failed

This error occurs during an attempt to perform a search and replace on build
files. If the operating system provided an error message it will be displayed
as well.

=head2 There are no loaders available for .EXT files

The file format inferred from the configuration file extension is not
supported.

=head2 These expected extra files are missing: FILES

=head2 These expected install files are missing from the build: FILES

=head2 These install files were not expected: FILES

=head2 These expected stow files are missing from the stow package: FILES

=head2 These stow package files were not expected: FILES

These warning messages are displayed when the module detects changes between
the newly downloaded project files and those project files defined in the
configuration and present in the stow package.

=head2 Unable to generate list of candidate configuration directories

Occurs if the module is unable to generate any candidate configuration
directories.

=head2 Write failed

This error occurs during an attempt to perform a search and replace on build
files. If the operating system provided an error message it will be displayed
as well.

=head1 INCOMPATIBILITIES

None known.

=head1 DEPENDENCIES

=head2 Perl modules

App::My::PandocUpdateFilters::FilepathMapping,
App::My::PandocUpdateFilters::Substitution, Carp, Const::Fast, English, Env,
Feature::Compat::Try, File::Copy, File::chdir, Git::Repository,
JSON::Validator::Schema::Draft201909, List::SomeUtils, Moo, MooX::Options,
namespace::clean, Path::Tiny, Role::Utils::Dn, Scalar::Util, strictures,
Types::Path::Tiny, Types::Standard, URI, version.

=head2 INCOMPATIBILITIES

There are no known incompatibilities with other modules.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2026 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
