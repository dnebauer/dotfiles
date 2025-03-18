package App::Dn::RTNG::Quit;

# modules    {{{1
use Moo;
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean -except => [ '_options_data', '_options_config' ];
use App::Dn::RTNG::Library;    # NOTE: ignore syntax warning (see note below)
use Types::Standard;
use MooX::Options (
  authors     => 'David Nebauer <david at nebauer dot org>',
  description => 'Uses the Radiotray NG DBus interface to'
      . ' quit the application.',
  protect_argv => 0,
);                             # }}}1

# attributes

# _rtng_interface    {{{1
has '_rtng_interface' => (
  is            => 'ro',
  isa           => Types::Standard::InstanceOf ['Net::DBus::RemoteObject'],
  default       => sub { return App::Dn::RTNG::Library->new->interface; },
  documentation => 'Interface to DBus Radiotray NG service',
);    # }}}1

# methods

# run()    {{{1
#
# does:   main method
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub run ($self) {
  $self->_rtng_interface->quit;
  return;
}    # }}}1

1;

#  WARNING: ignore "BEGIN failed" syntax warnings
# • the script that loaded App::Dn::RTNG::Quit did so by adding its
#   directory to @INC
# • App::Dn::RTNG::Library is in the same directory, but the perlcritic
#   static analyser does not know that, hence the error

# POD    {{{1

__END__

=head1 NAME

App::Dn::RTNG::Quit - quit the S<Radiotray NG> application

=head1 VERSION

This documentation is for C<App::Dn::RTNG::Quit> version 0.1.

=head1 SYNOPSIS

    use App::Dn::RTNG::Quit;

    App::Dn::RTNG::Quit->new_with_options->run;

=head1 DESCRIPTION

Uses the S<Radiotray NG> DBus interface to quit the application.

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

The only public method. It uses the S<Radiotray NG> DBus interface to quit the
application.

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

App::Dn::RTNG::Library, namespace::clean, Moo, MooX::Options, strictures,
Types::Standard, version.

=head1 AUTHOR

L<David Nebauer|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2025 L<David Nebauer|mailto:david@nebauer.org>

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
