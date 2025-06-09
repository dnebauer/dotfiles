#!/usr/bin/env perl

# modules    {{{1
# • utf8 is required by Text::Unidecode
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use charnames qw( :full );
use Carp;
use Const::Fast;
use Date::Parse;
use Email::MIME;
use English;
use IO::Interactive;
use List::SomeUtils;
use Path::Tiny;
use Text::Unidecode;
use Time::Piece;
use utf8;    ## no critic (ProhibitUnnecessaryUTF8Pragma)

binmode STDIN, ':encoding(UTF-8)';

# constants    {{{1
const my $TRUE       => 1;
const my $DATE       => 'Date';
const my $NO_DATE    => 'Error: Unable to extract header date field';
const my $NO_SUBJECT => 'Error: Unable to extract header subject field';
const my $NO_STDIN   => 'Error: No standard input received';
const my $SUBJECT    => 'Subject';
const my $SUBJECT_MAX_LENGTH => 40;

# get directory path from command line    {{{1
my $arg_count = @ARGV;
if ($arg_count != 1) { die "Error: Expected 1 argument, got $arg_count\n"; }
my $dirpath = Path::Tiny::path(shift @ARGV);
if (not $dirpath->is_dir) { die "Error: Invalid directory: '$dirpath'\n"; }

# test for stdin    {{{1
# • not sure why this logic works, but it does
if (IO::Interactive::is_interactive) { die "$NO_STDIN\n"; }

# read email content from stdin    {{{1
my $message = do { local $INPUT_RECORD_SEPARATOR = undef; <> };
if (not $message) { die "$NO_STDIN\n"; }

# extract email date and subject field contents    {{{1
# • header_str_pairs decodes field contents, including MIME encoded word syntax
# • do case-insensitive header name search - can be 'date' or 'Date', etc.
my %headers      = Email::MIME->new($message)->header_str_pairs;
my @header_names = keys %headers;
my $date_header  = List::SomeUtils::first_value {/date/xsmi} @header_names;
if (not $date_header)                   { die "$NO_DATE\n"; }
if (not defined $headers{$date_header}) { die "$NO_DATE\n"; }
my $field_date = $headers{$date_header};
if (not $field_date) { die "$NO_DATE\n"; }
my $subject_header =
    List::SomeUtils::first_value {/subject/xsmi} @header_names;
if (not $subject_header)                   { die "$NO_SUBJECT\n"; }
if (not defined $headers{$subject_header}) { die "$NO_SUBJECT\n"; }
my $field_subject = $headers{$subject_header};
if (not $field_date) { warn "$NO_SUBJECT\n"; }

# convert date to iso format for use in output file name    {{{1
my $epoch = Date::Parse::str2time($field_date);
my $date  = Time::Piece->strptime($epoch, '%s')->ymd;
if (not $date) { die "Error: Unable to convert date value\n"; }

# convert subject for use in output file name    {{{1
# • unidecode() converts to ascii; s/[^[:ascii:]]/ strips remaining non-ascii
# • ignore perlcritic preference for utf8-ish '[:lower:]' over ascii-ish 'a-z'
my $subject;
if ($field_subject) {
  $subject = lc $field_subject;
  $subject = Text::Unidecode::unidecode($subject);
  ## no critic (ProhibitEnumeratedClasses)
  $subject =
      $subject =~ s/[^[:ascii:]]/\N{SPACE}/xsmgr
      =~ s/[^a-z0-9\N{HYPHEN-MINUS}]/\N{SPACE}/xsmgr =~ y/\N{SPACE}/-/r
      =~ s/-{2,}/-/xsmgr;
  ## use critic
  $subject = substr $subject, 0, $SUBJECT_MAX_LENGTH;
  $subject = $subject =~ s/\A-*//xsmr =~ s/-*\z//xsmr;
}

# construct output filepath    {{{1
my $basename = ($subject) ? "${date}_${subject}" : $date;
my $filepath = Path::Tiny::path("$dirpath/$basename.eml");

# write to output file    {{{1
if ($filepath->exists) { die "Error: File '$filepath' already exists\n"; }
$filepath->spew_utf8($message);
say "Saved to $filepath" or croak;    # }}}1

1;

# POD    {{{1
__END__

=encoding utf8

=head1 NAME

neomutt_save-eml-file - save email file to download directory

=head1 VERSION

This documentation is for neomutt_save-eml-file version 0.1.

=head1 USAGE

B<neomutt_save-eml-file> I<download_dir>

=head1 OPTIONS

Nil.

=head1 REQUIRED ARGUMENTS

=over

=item B<download_dir>

The absolute path to the directory in which the email file is to be saved.

Scalar string. Required.

=back

=head1 REQUIRED OPTIONS

Nil.

=head1 OPTIONS

Nil.

=head1 DESCRIPTION

This script saves an email message to disk.

B<This script expects an email message (in F<eml> format) to be provided via
F<stdin>.>

=head2 Save file path

The email is saved to the directory specified in the single required script
argument.

The email's date and subject provide the basis for the saved file name.
The file name template is:

    YYYY-MM-DD_subject.eml

where the email date header is converted to ISO 8601 and the email subject
header undergoes the following transformations:

=over

=item *

converted to lowercase

=item *

attempted conversion of all non-ascii characters to equivalent ascii characters

=item *

converted all remaining non-ascii characters to spaces

=item *

converted most non-alphanumeric characters to spaces

=item *

converted spaces to dashes

=item *

converted multi-dash sequences to single dashes

=item *

truncated to 40 characters if longer than 40 characters

=item *

leading and trailing dashes trimmed.

=back

If a file with the same name already exists in the download directory,
the script exits with an error message.

=head2 Use in neomutt

This script is intended to be called in neomutt's I<index> or I<pager> menus.

It can be called by this neomutt macro provided the variables
C<$my_save_eml> and C<$my_download_dir> are set appropriately:

    macro index,pager X "\
    <enter-command>set my_wait_key=\$wait_key<enter>\
    <enter-command>set wait_key<enter>\
    <pipe-message>\
    $my_save_eml $my_download_dir<enter>\
    <enter-command>set wait_key=\$my_wait_key<enter>\
    <enter-command>unset my_wait_key<enter>\
    " 'save message to eml file in download dir'

=head1 DIAGNOSTICS

=head2 Expected 1 argument, got NUM

Occurs if no arguments are provided to the script, or more than S<1 argument>
is provided to the script.
Fatal error.

=head2 Invalid directory: PATH

Occurs if an invalid directory path is provided.
The script expects an absolute argument.
There is no guarantee a relative argument will work correctly.
Fatal error.

=head2 No standard input received

Occurs if no input is provided via stdin.
Fatal error.

=head2 Output file 'FILEPATH' already exists

Occurs if the output file path already exists.
Fatal error.

=head2 Unable to convert date value

Occurs if the script is unable to convert the header date field contents to an
S<ISO 8601> value.
Fatal error.

=head2 Unable to extract header date field

=head2 Unable to extract header subject field

Occurs if the script is unable to extract and convert an email header field.
Fatal error.

=head1 DEPENDENCIES

=head2 Perl modules

Carp, charnames, Const::Fast, Date::Parse, Email::MIME, English,
IO::Interactive, List::SomeUtils, Path::Tiny, strictures, Text::Unidecode,
Time::Piece, utf8, version.

=head1 CONFIGURATION

There are no configuration files or environmental variables that alter the
behaviour of this script.

=head1 INCOMPATIBILITIES

There are no known incompatibilities.

=head1 EXIT STATUS

The exit code is 0 for successful execution and 1 if the script does a
controlled exit following an error. If the script crashes unexpectedly the
error code is that given by the system.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 AUTHOR

David Nebauer (david at nebauer dot org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2024 David Nebauer (david at nebauer dot org)

This script is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

# vim:foldmethod=marker:
