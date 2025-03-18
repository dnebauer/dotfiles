package App::Dn::RTNG::Station;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;
use Const::Fast;
use Types::Standard;
use URI;

const my $TRUE => 1;    # }}}1

# attributes

# name    {{{1
has 'name' => (
  is       => 'ro',
  isa      => Types::Standard::Str,
  required => $TRUE,
  doc      => 'Station name',
);

# url    {{{1
has 'url' => (
  is       => 'ro',
  isa      => Types::Standard::InstanceOf ['URI'],
  required => $TRUE,
  doc      => 'Station url',
);    # }}}1

1;

# POD    {{{1

__END__

=head1 NAME

App::Dn::RTNG::Station - utility module modelling a station

=head1 VERSION

This documentation is for C<App::Dn::RTNG::Station> version 0.1.

=head1 SYNOPSIS

    use App::Dn::RTNG::Station;

=head1 DESCRIPTION

Store details of a radio station defined in S<Radiotray NG>.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

None.

=head2 Attributes

=over

=item $name

Station name as extracted from S<Radiotray NG> bookmark data. String. Required.

=item $url

Station url as extracted from S<Radiotray NG> bookmark data. URI object.
Required.

=back

=head2 Configuration files

None used.

=head2 Environment variables

None used.

=head1 SUBROUTINES/METHODS

None.

=head1 DIAGNOSTICS

No failure modes are documented.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

namespace::clean, Moo, MooX::HandlesVia, strictures, Types::Standard, URI,
version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
