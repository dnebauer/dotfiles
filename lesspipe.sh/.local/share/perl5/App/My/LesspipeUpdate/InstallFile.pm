package App::My::LesspipeUpdate::InstallFile;

use Moo;    # {{{1
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;

use Const::Fast;
use Types::Path::Tiny;

const my $TRUE => 1;    # }}}1

# attributes

# install_file_path    {{{1
has 'install_file_path' => (
  is       => 'ro',
  isa      => Types::Path::Tiny::AbsPath,
  required => $TRUE,
  coerce   => $TRUE,
  doc      => 'Path to install file',
);

# stow_file_path    {{{1
has 'stow_file_path' => (
  is       => 'ro',
  isa      => Types::Path::Tiny::AbsPath,
  required => $TRUE,
  coerce   => $TRUE,
  doc      => 'Path to mapped stow package file',
);    # }}}1

1;

# POD    {{{1
__END__

=encoding utf8

=head1 NAME

App::My::LesspipeUpdate::InstallFile - model a build file

=head1 VERSION

This documentation is for App::My::LesspipeUpdate::InstallFile version 0.1.

=head1 SYNOPSIS

    use Moo;
    use Const::Fast;
    use MooX::HandlesVia;
    use Types::Standard;
    use App::My::LesspipeUpdate::InstallFile;

    const my $TRUE => 1;

    has '_install_filepath_array' => (
      is  => 'rw',
      isa => Types::Standard::ArrayRef [
        Types::Standard::InstanceOf ['App::My::LesspipeUpdate::InstallFile'],
      ],
      required    => $TRUE,
      default     => sub { [] },
      handles_via => 'Array',
      handles     => {
        _install_files    => 'elements',
        _add_install_file => 'push',
      },
      doc => 'Array of install file objects',
    );

=head1 DESCRIPTION

This is an accessory module for L<App::My::LesspipeUpdate::Update> that models
a single file from a build of the lesspipe.sh project and the stow package
file it maps to.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties/attributes

=head3 install_file_path

The path to an install/build file from a built lesspipe.sh project.

A L<Types::Path::Tiny::AbsPath> object, which can accept a L<Path::Tiny>
object. Required.

=head3 stow_file_path

The path to a stow package file that maps to the install/build file defined
in the "install_file_path" attribute.

A L<Types::Path::Tiny::AbsPath> object, which can accept a L<Path::Tiny>
object. Required.

=head2 Configuration file

None used.

=head1 SUBROUTINES/METHODS

None.

=head1 DIAGNOSTICS

This module emits no custom error or warning messages.

=head1 INCOMPATIBILITIES

None known.

=head1 DEPENDENCIES

=head2 Perl modules

Const::Fast, Moo, namespace::clean, strictures, Types::Path::Tiny, version.

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
