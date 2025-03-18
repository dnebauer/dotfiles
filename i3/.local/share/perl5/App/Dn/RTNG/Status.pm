package App::Dn::RTNG::Status;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean -except => [ '_options_data', '_options_config' ];
use App::Dn::RTNG::Library;    # NOTE: ignore syntax warning (see note below)
use Const::Fast;
use Types::Standard;
use MooX::Options (
  authors      => 'David Nebauer <david at nebauer dot org>',
  description  => 'Display current status of Radiotray NG',
  protect_argv => 0,
);
const my $TRUE => 1;           # }}}1

# attributes

# _rtng_library    {{{1
has '_rtng_library' => (
  is            => 'ro',
  isa           => Types::Standard::InstanceOf ['App::Dn::RTNG::Library'],
  default       => sub { return App::Dn::RTNG::Library->new; },
  documentation => 'Instance of the RTNG library',
);    # }}}1

# methods

# run()    {{{1
#
# does:   main method
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub run ($self) {

  # obtain radiotry-ng status, construct a message, and display it
  my $status_msg = $self->_rtng_library->status_message;
  $self->_rtng_library->notify($status_msg);

  return;
}    # }}}1

1;

#  WARNING: ignore "BEGIN failed" syntax warnings
# • the script that loaded App::Dn::RTNG::Stop did so by adding its
#   directory to @INC
# • App::Dn::RTNG::Library is in the same directory, but the perlcritic
#   static analyser does not know that, hence the error

# POD    {{{1

__END__

=head1 NAME

App::Dn::RTNG::Status - display current status of S<Radiotray NG>

=head1 VERSION

This documentation is for C<App::Dn::RTNG::Status> version 0.1.

=head1 SYNOPSIS

    use App::Dn::RTNG::Status;

    App::Dn::RTNG::Status->new_with_options->run;

=head1 DESCRIPTION

Obtains details of S<Radiotray NG's> current state using its DBus interface and
displays key details in a system notification.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Properties

None.

=head2 Attributes

None.

=head2 Configuration files

None used.

=head2 Environment variables

None used.

=head1 SUBROUTINES/METHODS

=head2 run()

The only public method. It displays the current status of S<Radiotray NG> as
described in L</DESCRIPTION>.

=head1 DIAGNOSTICS

=head2 org.freedesktop.DBus.Error.ServiceUnknown

The full error is:

    org.freedesktop.DBus.Error.ServiceUnknown:
    The name com.github.radiotray_ng was not provided by any .service files

The commonest cause of this error is that S<Radiotray NG> is not running.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 DEPENDENCIES

=head2 Perl modules

App::Dn::RTNG::Library, Const::Fast, namespace::clean, Moo, MooX::Options,
strictures, Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
