package App::Dn::KDEConnect::CommandResult;

# modules    {{{1
use Moo;
use strictures 2;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;
use Const::Fast;
use MooX::HandlesVia;
use Types::Standard;

const my $TRUE => 1;    # }}}1

# attributes

# success    {{{1
has 'success' => (
  is            => 'ro',
  isa           => Types::Standard::Bool,
  required      => $TRUE,
  documentation => 'Whether command succeeded',
);

# error    {{{1
has 'error' => (
  is            => 'ro',
  isa           => Types::Standard::Str,
  required      => $TRUE,
  documentation => 'Error message if command failed',
);

# full_output    {{{1
has 'full_output' => (
  is            => 'ro',
  isa           => Types::Standard::ArrayRef [Types::Standard::Str],
  required      => $TRUE,
  handles_via   => 'Array',
  handles       => { full => 'elements', has_full => 'count', },
  documentation => 'Full output (stdout and stderr)',
);

# standard_out    {{{1
has 'standard_out' => (
  is            => 'ro',
  isa           => Types::Standard::ArrayRef [Types::Standard::Str],
  required      => $TRUE,
  handles_via   => 'Array',
  handles       => { stdout => 'elements', has_stdout => 'count', },
  documentation => 'Standard output',
);

# standard_err    {{{1
has 'standard_err' => (
  is            => 'ro',
  isa           => Types::Standard::ArrayRef [Types::Standard::Str],
  required      => $TRUE,
  handles_via   => 'Array',
  handles       => { stderr => 'elements', has_stderr => 'count', },
  documentation => 'Standard error',
);    # }}}1

1;

__END__

=head1 NAME

App::Dn::KDEConnect::CommandResult - returned by App::Dn::KDEConnect::Library->capture_command_output

=head1 VERSION

This documentation is for C<App::Dn::KDEConnect::CommandResult> version 0.1.

=head1 SYNOPSIS

    use App::Dn::KDEConnect::CommandResult;

    my $cmd = [ ... ];
    my $result = $self->capture_command_output($cmd);
    if ( $result->success ) {
        ...
    }

=head1 DESCRIPTION

Captures results of running a command with the C<App::Dn::KDEConnect::Monitor>
method C<_capture_command_output>.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

None.

=head2 Attributes

=head3 success

Whether command succeeded. Scalar boolean.

=head3 error

Error message. Scalar string. (Undef if command succeeded.)

=head3 full

Full output, includes standard output and standard error.
List of strings with no trailing newlines.

=head3 has_full

Whether there is any output.
Scalar boolean (actually the number of output lines).

=head3 stdout

Output sent to standard out. List of strings with no trailing newlines.

=head3 has_stdout

Whether there was output to standard out.
Scalar boolean (actually the number of lines).

=head3 stderr

Standard error. List of strings with no trailing newlines.

=head3 has_stderr

Whether there was output to standard error.
Scalar boolean (actually the number of lines).

=head2 Configuration files

None used.

=head2 Environment variables

None used.

=head1 SUBROUTINES/METHODS

Nil.

=head1 DIAGNOSTICS

No failure modes are documented.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

Const::Fast, Moo, MooX::HandlesVia, namespace::clean, strictures,
Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
