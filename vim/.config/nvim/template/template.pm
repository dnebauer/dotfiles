package Dn::Package;

use Moo;    # {{{1
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean;

use autodie qw(open close);
use Carp    qw(confess);
use Const::Fast;
use Dn::InteractiveIO;
use English;
use MooX::HandlesVia;
use Path::Tiny;
use Sys::Syslog qw(:DEFAULT setlogsock);
use Syntax::Keyword::Try;
use Types::Standard;

with qw(Role::Utils::Dn);

const my $TRUE  => 1;
const my $FALSE => 0;
my $io = Dn::InteractiveIO->new;
Sys::Syslog::openlog('ident', 'user');    # }}}1
    # ident is prepended to every message - adapt to module
    # user is the most commonly used facility - leave as is

# debug
use Data::Dumper::Simple;

# attributes

# log    {{{1
has 'log' => (
  is            => 'ro',
  isa           => Types::Standard::Bool,
  required      => $FALSE,
  default       => $FALSE,
  documentation => 'Whether to write status messages to system log',
);

# _attr_1    {{{1
has '_attr_1' => (
  is            => 'ro',
  isa           => Types::Standard::Str,
  lazy          => $TRUE,
  default       => sub { return My::App->new->get_value; },
  documentation => 'Insert here',
);

# _attr_list    {{{1
has '_attr_list' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf ['Config::Simple'],
  ],
  lazy        => $TRUE,
  default     => sub { [] },
  handles_via => 'Array',
  handles     => {
    _attrs    => 'elements',
    _add_attr => 'push',
    _has_attr => 'count',
  },
  documentation => 'Array of values',
);    # }}}1

# methods

# my_method($thing)    {{{1
#
# does:   it does stuff
# params: $thing - for this [optional, default=grimm]
# prints: nil
# return: scalar boolean
sub my_method ($self) {    ## no critic (RequireInterpolationOfMetachars)
  $io->say('This is feedback');
  return $FALSE;
}

# _log($msg, [$type])    {{{1
#
# does:   log message if logging
# params: $msg  - message [scalar string, optional, no default]
#         $type - message type [scalar string, optional, default=INFO]
#                 can be EMERG|ALERT|CRIT|ERR|WARNING|NOTICE|INFO|DEBUG
# prints: nil
# return: n/a, dies on failure
# note:   appends most recent system error message for message types
#         EMERG, ALERT, CRIT and ERR
sub _log ($self, $msg, $type) { ## no critic (RequireInterpolationOfMetachars)

  # only log if logging
  return if not $self->log;

  # check params
  return if not defined $msg;
  if (not $type) { $type = 'INFO'; }
  my %valid_type = map { ($_ => $TRUE) }
      qw(EMERG ALERT CRIT ERR WARNING NOTICE INFO DEBUG);
  if (not $valid_type{$type}) { $self->_fail("Invalid type '$type'"); }

  # display system error message for serious message types
  my %error_type = map { ($_ => $TRUE) } qw(EMERG ALERT CRIT ERR);
  if ($error_type{$type}) { $msg .= ': %m'; }

  # log message
  Sys::Syslog::syslog($type, $msg);

  return;
}

# _fail($err)    {{{1
#
# does:   print stack trace if interactive, log message if logging,
#         and exit with error status
#
# params: $err - error message [scalar string, required]
# prints: error message
# return: n/a, dies on completion
sub _fail ($self, $err) {    ## no critic (RequireInterpolationOfMetachars)

  # log error message (if logging)
  $self->_log($err, 'ERR');

  # exit with failure status, printing stack trace if interactive
  if   ($io->interactive) { confess $err; }
  else                    { exit 1; }
}

# _other($err)    {{{1
#
# does:   do the other thing
#
# params: nil
# prints: error message
# return: n/a, dies on completion
sub _other ($self) {    ## no critic (RequireInterpolationOfMetachars)
}                       # }}}1

1;

# POD    {{{1

## no critic (RequirePodSections)

__END__

=encoding utf8

=head1 NAME

Dn::Package - what I do

=head1 VERSION

This documentation is for Dn::Package version 0.1.

=head1 SYNOPSIS

    use Dn::Package;
    ...

=head1 DESCRIPTION

Full description. May have subsections.

=head1 SUBROUTINES/METHODS

=head2 method1($param)

Method purpose.

=head3 Params

=over

=item $param

Parameter details. Scalar string. Required.

=back

=head3 Prints

Nil.

=head3 Returns

Nil.

=head1 DIAGNOSTICS

Supposedly a listing of every error and warning message that the module can
generate (even the ones that will "never happen"), with a full explanation of
each problem, one or more likely causes, and any suggested remedies.

Really?

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

=head3 Attribute1

Explain use of Attribute1.

=head2 Configuration

This module does not use configuration files.

=head2 Environment

This module does not use environmental variables.

=head1 DEPENDENCIES

=head2 Perl modules

autodie, Carp, Const::Fast, Dn::InteractiveIO, English, Moo, MooX::HandlesVia,
namespace::clean, Path::Tiny, Role::Utils::Dn, strictures, Sys::Syslog,
Syntax::Keyword::Try, Types::Common::Numeric, Types::Common::String,
Types::Path::Tiny, Types::Standard, version.

=head2 INCOMPATIBILITIES

There are no known incompatibilities with other modules.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 AUTHOR

David Nebauer E<lt>david@nebauer.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2024 ${author}

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
