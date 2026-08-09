package App::My::LesspipeUpdate::Substitution;

use Moo;    # {{{1
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;

use Const::Fast;
use Types::Standard;

const my $TRUE => 1;    # }}}1

# attributes

# pattern    {{{1
has 'pattern' => (
  is       => 'ro',
  isa      => Types::Standard::Str,
  required => $TRUE,
  doc      => 'Pattern to search for (plain string)',
);

# replacement    {{{1
has 'replacement' => (
  is       => 'ro',
  isa      => Types::Standard::Str,
  required => $TRUE,
  doc      => 'Replacement string',
);    # }}}1

1;

# POD    {{{1
__END__

=encoding utf8

=head1 NAME

App::My::LesspipeUpdate::Substitution - model a single file substitution

=head1 VERSION

This documentation is for App::My::LesspipeUpdate::Substitution version 0.1.

=head1 SYNOPSIS

    use Moo;
    use Const::Fast;
    use MooX::HandlesVia;
    use Types::Standard;
    use App::My::LesspipeUpdate::Substitution;

    const my $TRUE => 1;

    has '_substitutions_array' => (
      is  => 'rw',
      isa => Types::Standard::ArrayRef [
        Types::Standard::InstanceOf ['Dn::Internal::Substitution'],
      ],
      required    => $TRUE,
      default     => sub { [] },
      handles_via => 'Array',
      handles     => {
        _substitutions    => 'elements',
        _add_substitution => 'push',
      },
      doc => 'String substitutions for repo files',
    );

=head1 DESCRIPTION

This is an accessory module for L<App::My::LesspipeUpdate::Update> that models
a single text file substitution.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties/attributes

=head3 pattern

A pattern to search for. Scalar string. Required.

=head3 replacement

A replacement string. Scalar string. Required.

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

Const::Fast, Moo, namespace::clean, strictures, Types::Standard, version.

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
