package App::My::PandocUpdateFilters::FilepathMapping;

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

# downloaded_file_path    {{{1
has 'downloaded_file_path' => (
  is       => 'ro',
  isa      => Types::Path::Tiny::AbsPath,
  required => $TRUE,
  coerce   => $TRUE,
  doc      => 'Path to a downloaded repo file',
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

App::My::PandocUpdateFilters::FilepathMapping - model a mapping between repo and stow files

=head1 VERSION

This documentation is for App::My::PandocUpdateFilters::FilepathMapping
version 0.1.

=head1 SYNOPSIS

    use Moo;
    use Const::Fast;
    use Types::Standard;
    use App::My::PandocUpdateFilters::FilepathMapping;

    const my $TRUE => 1;

    has '_filepath_mapping_array' => (
      is  => 'rw',
      isa => Types::Standard::ArrayRef [
        Types::Standard::InstanceOf ['App::My::PandocUpdateFilters::FilepathMapping'],
      ],
      required => $TRUE,
      default  => sub { [] },
      doc      => 'Array of install file objects',
    );

=head1 DESCRIPTION

This is an accessory module for L<App::My::PandocUpdateFilters::Update> that
models a downloaded repository files and its corresponding stow package
filters directory file.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties/attributes

=head3 downloaded_file_path

The path to a downloaded file from an online repository.

A L<Types::Path::Tiny::AbsPath> object, which can accept a L<Path::Tiny>
object. Required.

=head3 stow_file_path

The path to a stow package file that maps to the downloaded repository file
defined in the "downloaded_file_path" attribute.

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
