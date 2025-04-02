package App::Dn::KDEConnect::Device;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;
use Const::Fast;
use Types::Standard;

const my $TRUE               => 1;
const my $FALSE              => 0;
const my $MAX_CHECKS_TO_SKIP => 8;    # }}}1

# attributes

# menu    {{{1
has 'name' => (
  is       => 'ro',
  isa      => Types::Standard::Str,
  required => $TRUE,
  doc      => 'Name of device',
);

# id    {{{1
has 'id' => (
  is       => 'ro',
  isa      => Types::Standard::Str,
  required => $TRUE,
  doc      => 'Device id',
);

# connected    {{{1
has 'connected' => (
  is       => 'rw',
  isa      => Types::Standard::Bool,
  required => $TRUE,
  default  => $FALSE,
  doc      => 'Whether device is connected',
);

# checks_failed    {{{1
has 'checks_failed' => (
  is       => 'rw',
  isa      => Types::Standard::Int,
  required => $TRUE,
  default  => 0,
  doc      => 'Number of connection checks consecutively failed',
);

# checks_skipped    {{{1
has 'checks_skipped' => (
  is       => 'rw',
  isa      => Types::Standard::Int,
  required => $TRUE,
  default  => 0,
  doc      => 'Number of checks skipped to date',
);

# checks_to_skip    {{{1
has 'checks_to_skip' => (
  is       => 'rw',
  isa      => Types::Standard::Int,
  required => $TRUE,
  default  => 0,
  doc      => 'Number of checks to skip',
);    # }}}1

# methods

# increase_checks_to_skip    {{{1
#
# does:   increase the number of checks to skip
#         0 -> 1 -> 2 -> 4 -> 8
# params: nil
# prints: nil
# return: n/a
sub increase_checks_to_skip ($self) {
  my $checks_to_skip = $self->checks_to_skip;
  if    ($checks_to_skip == 0)                  { $checks_to_skip = 1; }
  elsif ($checks_to_skip < $MAX_CHECKS_TO_SKIP) { $checks_to_skip *= 2; }
  $self->checks_to_skip($checks_to_skip);
  return;
}

# increment_checks_failed    {{{1
#
# does:   increment the number of checks failed
# params: nil
# prints: nil
# return: n/a
sub increment_checks_failed ($self) {
  my $checks_failed = $self->checks_failed;
  ++$checks_failed;
  $self->checks_failed($checks_failed);
  return;
}

# increment_checks_skipped    {{{1
#
# does:   increment the number of checks failed
# params: nil
# prints: nil
# return: n/a
sub increment_checks_skipped ($self) {
  my $checks_skipped = $self->checks_skipped;
  ++$checks_skipped;
  $self->checks_skipped($checks_skipped);
  return;
}    # }}}1

1;

# POD    {{{1

__END__

=head1 NAME

App::Dn::KDEConnect::Device - model the properties of a connectable device

=head1 VERSION

This documentation applies to L<App::Dn::KDEConnect::Device> version 0.1.

=head1 SYNOPSIS

    use App::Dn::KDEConnect::Device;
    # ...
    my $device = App::Dn::KDEConnect::Device->new(
      name => $device_name,
      id   => $device_id,
    );

=head1 DESCRIPTION

This module models a connectable device.
It is used by L<App::Dn::KDEConnect::Monitor>.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

All properties are required.

=head3 name

Name of device as shown by C<kdeconnect-cli> when connected. String.

=head3 id

This single character must be unique within a menu.

Id of device as shown by C<kdeconnect-cli> when connected. String.

=head2 Attributes

=head3 connected

Whether device is connected. Boolean. Default: false.

=head3 checks_failed

Number of connection checks consecutively failed. Integer. Default: 0.

=head3 checks_skipped

Number of checks skipped to date. Integer. Default: 0.

=head3 checks_to_skip

Number of checks to skip. Integer. Default: 0.

=head2 Configuration files

None used.

=head2 Environmental variables

None used.

=head1 SUBROUTINES/METHODS

=head2 increase_checks_to_skip()

Increase the number of checks to skip. The increase progression is:

    0 -> 1 -> 2 -> 4 -> 8

=head3 Parameters

Nil.

=head3 Prints

Nil.

=head3 Returns

N/A.

=head2 increment_checks_failed()

Increase the L</checks_failed> attribute by 1.

=head3 Parameters

Nil.

=head3 Prints

Nil.

=head3 Returns

N/A.

=head2 increment_checks_skipped()

Increment the L</checks_skipped> attribute by 1.

=head3 Parameters

Nil.

=head3 Prints

Nil.

=head3 Returns

N/A.

=head1 DIAGNOSTICS

No warning or error messages are generated.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

Const::Fast, Moo, namespace::clean, strictures, Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
