package App::Dn::LesspipeUpdate::Update;

use Moo;    # {{{1
use strictures 2;
use 5.006;
use 5.038_001;
use version; our $VERSION = qv('0.1');
use namespace::clean -except => [ '_options_data', '_options_config' ];

# WARN: ignore syntax warnings for "BEGIN failed" and "Can't locate App::..."
# • The script that loaded this module did so by adding its directory
#   to @INC with File::FindLib
# • The App::... modules loaded below are in the same directory, but the
#   perlcritic static analyser does not know that, and hence the error
use App::Dn::LesspipeUpdate::InstallFile;
use App::Dn::LesspipeUpdate::Substitution;
use Carp qw(croak);
use Const::Fast;
use English;
use Env qw($HOME);
use Feature::Compat::Try;
use File::chdir;
use File::Compare;
use File::Copy;
use Git::Repository;
use JSON::Validator::Schema::Draft201909;
use List::SomeUtils;
use MooX::HandlesVia;
use MooX::Options (
  authors      => 'David Nebauer <david at nebauer dot org>',
  description  => 'Update a local installation of lesspipe.sh',
  protect_argv => 0,
);
use Path::Tiny;
use Scalar::Util;
use Types::Standard;
use Types::Path::Tiny;
use URI;

with qw(Role::Utils::Dn);

const my $TRUE            => 1;
const my $FALSE           => 0;
const my $DIR_TEMPLATE    => 'tmp.XXXXXXXXXX';
const my $WARNING         => 'warning';
const my $ERROR           => 'error';
const my $FILE_COMP_ERROR => -1;                 # }}}1

# options

# build_only (-b)    {{{1
option 'build_only' => (
  is    => 'ro',
  short => 'b',
  doc   => 'Download and build only (default: false)',
);

# tests (-t)    {{{1
option 'tests' => (
  is    => 'ro',
  short => 't',
  doc   => 'Run tests during repo project build (default: false)',
);    # }}}1

# attributes

# _install_dir    {{{1
has '_install_dir' => (
  is     => 'lazy',
  isa    => Types::Standard::InstanceOf ['Path::Tiny'],
  coerce => $TRUE,
  doc    => 'Directory in which built project is temporarily installed',
);

sub _build__install_dir ($self) {    ## no critic (ProhibitUnusedPrivateSubroutines)
  if ($self->build_only) {
    return Path::Tiny->tempdir(
      TEMPLATE => $DIR_TEMPLATE,
      CLEANUP  => $FALSE,
    );
  }
  else {
    return Path::Tiny->tempdir(TEMPLATE => $DIR_TEMPLATE);
  }
}

# _build_dir    {{{1
has '_build_dir' => (
  is     => 'lazy',
  isa    => Types::Standard::InstanceOf ['Path::Tiny'],          ## no critic (ProhibitDuplicateLiteral)
  coerce => $TRUE,
  doc    => 'Directory in which repo is downloaded and built',
);

sub _build__build_dir ($self) {    ## no critic (ProhibitUnusedPrivateSubroutines)
  if ($self->build_only) {
    return Path::Tiny->tempdir(
      TEMPLATE => $DIR_TEMPLATE,
      CLEANUP  => $FALSE,
    );
  }
  else {
    return Path::Tiny->tempdir(TEMPLATE => $DIR_TEMPLATE);
  }
}

# _repo_clone_url    {{{1
has '_repo_clone_url' => (
  is       => 'rw',
  isa      => Types::Standard::InstanceOf ['URI'],
  coerce   => $TRUE,
  required => $FALSE,
  doc      => 'URL of project online repository',
);

# _stow_root    {{{1
has '_stow_root' => (
  is       => 'rw',
  isa      => Types::Standard::Str,
  required => $FALSE,
  doc      => 'Root directory of stow packages',
);

# _stow_pkg    {{{1
has '_stow_pkg' => (
  is       => 'rw',
  isa      => Types::Standard::Str,
  required => $FALSE,
  doc      => 'Stow package name (i.e., package subdir name)',
);

# _stow_extras, _load_stow_extras    {{{1
has '_stow_extra_array' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf ['Path::Tiny'],    ## no critic (ProhibitDuplicateLiteral)
  ],
  required    => $TRUE,
  default     => sub { [] },
  handles_via => 'Array',
  handles     => {
    _stow_extras      => 'elements',
    _load_stow_extras => 'push',
  },
  doc => 'Stow package files not sourced from online project repo',
);

# _install_files, _add_install_file    {{{1
has '_install_filepath_array' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf ['App::Dn::LesspipeUpdate::InstallFile'],
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

# _substitutions, add_substitution    {{{1
has '_substitutions_array' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf ['App::Dn::LesspipeUpdate::Substitution'],
  ],
  required    => $TRUE,
  default     => sub { [] },
  handles_via => 'Array',
  handles     => {
    _substitutions    => 'elements',
    _add_substitution => 'push',
  },
  doc => 'String substitutions for repo files',
);    # }}}1

# methods

# run()    {{{1
#
# does:   main method
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub run ($self) {

  # load config file data
  $self->_load_from_config_file;

  # download repo
  $self->_download_repo;

  # build project
  $self->_build_project;
  return $FALSE if $self->build_only;

  # check whether project has changed filepaths
  # • changes displayed to user
  if ($self->_structural_project_changes) {
    say q{} or croak;
    if (not $self->interact_confirm('Proceed with update?')) {
      return $FALSE;
    }
  }

  # perform file substitutions
  $self->_do_file_content_substitutions;

  # update stow package files
  $self->_update_stow_package_files;

  return $FALSE;
}

# _build_project()    {{{1
#
# does:   build project in build directory
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub _build_project ($self) {

  # variables
  my $build_dir   = $self->_build_dir->canonpath;
  my $run_tests   = $self->tests;
  my $install_dir = $self->_install_dir->canonpath;

  # assemble commands
  # • the current configure options are:
  #   ----------------------------------------------------------------------
  #   Options:
  #    --help                   print this message
  #    --shell=<filename>       specify an alternative shell path
  #                             (zsh/bash) to use
  #    --nomake                 do not generate a Makefile
  #   Directory and file names:
  #    --prefix=PREFIX          install files below PREFIX (/usr/local)
  #    --bindir=BINDIR          install binaries in BINDIR (PREFIX/bin)
  #    --libexecdir=LIBEXECDIR  install lesscomplete in LIBEXECDIR
  #                             (PREFIX/libexec/lesspipe)
  #    --mandir=MANDIR          install man pages in in MANDIR
  #                             (PREFIX/share/man/man1)
  #    --bash-completion-dir=DIR install bash auto-completion file in in DIR
  #                             (pkg-config --variable=completionsdir
  #                              bash-completion)
  #    --zsh-completion-dir=DIR install zsh auto-completion file in in DIR
  #                             (PREFIX/share/zsh/site-functions)
  #   ----------------------------------------------------------------------
  # • specify as many as possible manually to future proof against project
  #   configuration changes
  my $b_completion = "$install_dir/etc/bashcompletion.d";
  my $z_completion = "$install_dir/share/zsh/completions";
  my @cmds;
  push @cmds,
      [
    './configure',
    qq{--prefix="$install_dir"},
    qq{--bindir="$install_dir/bin"},
    qq{--libexecdir="$install_dir/libexec/lesspipe"},
    qq{--mandir="$install_dir/share/man/man1"},
    qq{--bash-completion-dir="$b_completion"},
    qq{--zsh-completion-dir="$z_completion"},
      ];
  ## no critic (ProhibitDuplicateLiteral)
  push @cmds, ['make'];
  if ($run_tests) { push @cmds, [ 'make', 'test' ] }
  else            { say q{Will skip 'make test' step} or croak; }
  push @cmds, [ 'make', 'install' ];
  ## use critic

  # run commands
  {
    local $File::chdir::CWD = $build_dir;
    for my $cmd_ref (@cmds) {
      my @cmd = @{$cmd_ref};
      say q{Running '} . join(q{ }, @cmd) . q{':} or croak;
      $self->run_command(undef, @cmd);
    }
  }

  # provide feedback if building only
  if ($self->build_only) {
    say "  Build directory: $build_dir"   or croak;
    say "Install directory: $install_dir" or croak;
  }

  return $FALSE;
}

# _copy_files(@install_file_objs)    {{{1
#
# does:   copy new and changed project files into stow package
# params: @install_file_objs
#         [required, App::Dn::LesspipeUpdate::InstallFile objects]
# prints: feedback
# return: n/a
sub _copy_files ($self, @install_file_objs) {

  # check param
  my @not_path_tiny = grep {
    my $bls = Scalar::Util::blessed $_;
    not(defined $bls
      and $bls eq 'App::Dn::LesspipeUpdate::InstallFile');    ## no critic (ProhibitDuplicateLiteral)
  } @install_file_objs;
  if (@not_path_tiny) {
    my $count = @not_path_tiny;
    my $tpl   = "Expected all Path::Tiny objects, $count (was|were) not";
    my $msg   = $self->pluralise($tpl, scalar @not_path_tiny);
    $self->vim_print($ERROR, "\n$msg");
    die "Aborting update\n";
  }

  # do file copy
  my %replacing =
      map {
    $_->install_file_path->canonpath => $_->stow_file_path->canonpath
      } @install_file_objs;
  say "\nCopying updated project files into stow package:" or croak;
  for my $install_fp (sort keys %replacing) {
    my $stow_fp = $replacing{$install_fp};
    say "\n• $install_fp\n  -> $stow_fp" or croak;
    if (File::Copy::copy($install_fp, $stow_fp)) {
      say '  -- copied' or croak;
    }
    else {
      $self->vim_print($ERROR, "  -- failed: $OS_ERROR");
    }
  }
  say "\nCopying done" or croak;

  return $FALSE;
}

# _do_file_content_substitutions()    {{{1
#
# does:   perform substitutions on built files
# params: nil
# prints: feedback
# return: n/a
sub _do_file_content_substitutions ($self) {

  my @fps  = map { $_->install_file_path } $self->_install_files;
  my @subs = $self->_substitutions;

  my $print_heading = $FALSE;

  for my $fp (@fps) {
    next if not $fp->is_file;
    my $fpath = $fp->canonpath;
    my $data;
    try {
      $data = $fp->slurp_utf8;
    }
    catch ($err) {
      if   ($err) { $self->vim_print($ERROR, "Slurp failed: $err"); }
      else        { $self->vim_print($ERROR, "Slurp failed: $fpath"); }
    }
    my $print_fp = $FALSE;
    for my $sub (@subs) {
      my ($pattern, $replace) = ($sub->pattern, $sub->replacement);
      my $count = $data =~ s/$pattern/$replace/xsm;
      if ($count) {
        if (not $print_heading) {
          $print_heading = $TRUE;
          say "\nPerforming file text substitutions:" or croak;
        }
        if (not $print_fp) {
          $print_fp = $TRUE;
          say "\n• $fp:" or croak;
        }
        say "  - '$pattern'\n    -> '$replace'\n    ($count)" or croak;
      }
    }
    try {
      $fp->spew_utf8($data);
    }
    catch ($err) {
      if ($err) {
        if   ($err) { $self->vim_print($ERROR, "Write failed: $err"); }
        else        { $self->vim_print($ERROR, "Write failed: $fpath"); }
      }
    }
  }

  say "\nSubstitutions done" or croak;

  return $FALSE;
}

# _download_repo()    {{{1
#
# does:   download github repo to build directory
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub _download_repo ($self) {

  my $url = $self->_repo_clone_url;
  my $dir = $self->_build_dir->canonpath;
  my $opt = { fatal => '!0', quiet => $TRUE };

  say "Cloning repo $url" or croak;

  Git::Repository->run(clone => $url, $dir, $opt);

  return $FALSE;
}

# _load_from_config_file()    {{{1
#
# does:   load attributes from config file
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub _load_from_config_file ($self) {

  # load config file data
  my $conf = $self->config_file('dn-lesspipe-update');
  my $data = $conf->data;

  # check integrity of config data (dies on failure)
  $self->_validate_config_data($data);

  # assume data structure looks like this
  # • note placeholders HOME, INSTALL_DIR and STOW_PKG_DIR
  #   which are replaced using $self->_replace_placeholders()
  #
  # {
  #   "repo" : {
  #     "clone_url" : "https://github.com/wofr06/lesspipe.git"
  #   },
  #   "stow" : {
  #     "root" : "HOME/.config/dotfiles",
  #     "pkg" : "lesspipe.sh",
  #     "extra" : [ "STOW_PKG_DIR/.config/zshenv.d/lesspipe.sh.zsh", ... ],
  #   },
  #   "install" : {
  #     "filepath_maps" : [
  #       [ "INSTALL_DIR/subdir/file",
  #         "STOW_PKG_DIR/subdir/file"
  #       ],
  #       ...,
  #     ],
  #     "substitutions" : [
  #       [ "INSTALL_DIR/libexec/lpipe", "HOME/.local/libexec/lpipe" ],
  #       ...,
  #     ],
  #   },
  # }

  # set attributes needed to replace placeholders

  ## no critic (ProhibitDuplicateLiteral)
  # • _repo_clone_url
  my $url_string = $data->{'repo'}->{'clone_url'};
  my $url_object = URI->new($url_string);
  $self->_repo_clone_url($url_object);

  # • _stow_root
  my $stow_root = $data->{'stow'}->{'root'};
  $stow_root =~ s{HOME}{$HOME}gsm;
  $self->_stow_root($stow_root);

  # • _stow_pkg
  my $stow_pkg = $data->{'stow'}->{'pkg'};
  $self->_stow_pkg($stow_pkg);
  ## use critic

  # replace placeholders in config file data
  $self->_replace_placeholders($data);

  # set remaining attributes

  ## no critic (ProhibitDuplicateLiteral)
  # • _stow_extras
  my $stow_extras_array = $data->{'stow'}->{'extra'};
  my @stow_extras_orig  = @{$stow_extras_array};
  my @stow_extras       = map { Path::Tiny->new($_) } @stow_extras_orig;
  $self->_load_stow_extras(@stow_extras);

  # • _install_files
  my $install_mappings_array = $data->{'install'}->{'filepath_maps'};
  my @install_mappings_orig  = @{$install_mappings_array};
  for my $install_mapping (@install_mappings_orig) {
    my ($install_file_path, $stow_file_path) = @{$install_mapping};
    $self->_add_install_file(
      App::Dn::LesspipeUpdate::InstallFile->new(
        install_file_path => $install_file_path,
        stow_file_path    => $stow_file_path,
      )
    );
  }

  # • _substitutions
  my $substitution_pairs_array = $data->{'install'}->{'substitutions'};
  my @substitution_pairs       = @{$substitution_pairs_array};
  for my $substitution_pair (@substitution_pairs) {
    my ($pattern, $replacement) = @{$substitution_pair};
    $self->_add_substitution(
      App::Dn::LesspipeUpdate::Substitution->new(
        pattern     => $pattern,
        replacement => $replacement,
      )
    );
  }
  ## use critic

  return $FALSE;
}

# _replace_placeholders($data)    {{{1
#
# does:   replace config file placeholders in config file data
# params: nil
# prints: feedback
# return: n/a, operates on $data by reference
# note:   this method handles placeholders:
#         HOME, INSTALL_DIR and STOW_PKG_DIR
# note:   this method can only be called after the
#         'stow_root' and 'stow_pkg' attributes are set
sub _replace_placeholders ($self, $data) {

  croak 'INSTALL_DIR not set' if not $self->_install_dir;
  croak 'STOW_ROOT not set'   if not $self->_stow_root;
  croak 'STOW_PKG not set'    if not $self->_stow_pkg;

  my $install_dir  = $self->_install_dir->canonpath;
  my $stow_pkg_dir = $self->path_join($self->_stow_root, $self->_stow_pkg);

  my $placeholder_values = {
    INSTALL_DIR  => $install_dir,
    STOW_PKG_DIR => $stow_pkg_dir,
    HOME         => $HOME,
  };

  $self->replace_tokens($data, $placeholder_values);

  return $FALSE;
}

# _structural_project_changes()    {{{1
#
# does:   check whether file names or locations have changed
# params: nil
# prints: feedback
# return: boolean (whether changes found)
sub _structural_project_changes ($self) {

  my $structure_change_detected = $FALSE;

  # key directories
  my $install_dir = $self->_install_dir->canonpath;
  my $stow_dir    = $self->path_join($self->_stow_root, $self->_stow_pkg);

  # file lists to examine
  my @expected_install_fps = map { $_->canonpath }
      map { $_->install_file_path } $self->_install_files;
  my @actual_install_fps = $self->file_list_recursively($install_dir);
  my @expected_stow_fps  = map { $_->canonpath }
      map { $_->stow_file_path } $self->_install_files;
  my @extra_and_actual_stow_fps = $self->file_list_recursively($stow_dir);
  my @extra_stow_fps            = map { $_->canonpath } $self->_stow_extras;
  my @actual_stow_fps =
      $self->subtract_array([@extra_and_actual_stow_fps], [@extra_stow_fps]);

  # check that all extra-stow-fps are existing stow fps
  my @missing_expected_extra_fps =
      $self->compare_arrays([@extra_stow_fps], [@extra_and_actual_stow_fps])
      ->removed_elements;
  if (@missing_expected_extra_fps) {
    $structure_change_detected = $TRUE;
    my @fps =
        map {s/^$stow_dir/STOW_PKG_DIR/xsmr} @missing_expected_extra_fps;
    my $tpl = '(This|These) expected extra file(s) (is|are) missing:';
    my $msg = $self->pluralise($tpl, scalar @missing_expected_extra_fps);
    $self->vim_print($WARNING, "\n$msg");
    for my $fp (@fps) { $self->vim_print($WARNING, "• $fp"); }
  }

  # compare expected and actual install fps
  my $cmp_install =
      $self->compare_arrays([@expected_install_fps], [@actual_install_fps]);
  if ($cmp_install->elements_removed) {
    $structure_change_detected = $TRUE;
    my @removed =
        map {s/^$install_dir/INSTALL_DIR/xsmr} $cmp_install->removed_elements;
    my $tpl = '(This|These) expected install file(s) (is|are) '
        . 'missing from the build:';
    my $msg = $self->pluralise($tpl, scalar @removed);
    $self->vim_print($WARNING, "\n$msg");
    for my $file (@removed) { $self->vim_print($WARNING, "• $file"); }
  }
  if ($cmp_install->elements_added) {
    $structure_change_detected = $TRUE;
    my @added =
        map {s/^$install_dir/INSTALL_DIR/xsmr} $cmp_install->added_elements;
    my $tpl = '(This|These) install file(s) (was|were) not expected:';
    my $msg = $self->pluralise($tpl, scalar @added);
    $self->vim_print($WARNING, "\n$msg");
    for my $file (@added) { $self->vim_print($WARNING, "• $file"); }
  }

  # compare expected and actual stow fps
  my $cmp_stow =
      $self->compare_arrays([@expected_stow_fps], [@actual_stow_fps]);
  if ($cmp_stow->elements_removed) {
    $structure_change_detected = $TRUE;
    my @removed =
        map {s/^$stow_dir/STOW_PKG_DIR/xsmr} $cmp_stow->removed_elements;
    my $tpl = '(This|These) expected stow file(s) (is|are) '
        . 'missing from the stow package:';
    my $msg = $self->pluralise($tpl, scalar @removed);
    $self->vim_print($WARNING, "\n$msg");
    for my $file (@removed) { $self->vim_print($WARNING, "• $file"); }
  }
  if ($cmp_stow->elements_added) {
    $structure_change_detected = $TRUE;
    my @added =
        map {s/^$stow_dir/STOW_PKG_DIR/xsmr} $cmp_stow->added_elements;
    my $tpl = '(This|These) stow package file(s) (was|were) not expected:';
    my $msg = $self->pluralise($tpl, scalar @added);
    $self->vim_print($WARNING, "\n$msg");
    for my $file (@added) { $self->vim_print($WARNING, "• $file"); }
  }

  if ($structure_change_detected) {
    say "\nConsider:\n",
        "• updating the config file\n",
        "• deleting unneeded stow package files\n",
        "  and deleting corresponding dangling symlinks\n",
        '• re-stowing the package after update'
        or croak;
  }

  return $structure_change_detected;
}

# _update_stow_package_files()    {{{1
#
# does:   copy new and changed project files into stow package
# params: nil
# prints: feedback
# return: n/a
sub _update_stow_package_files ($self) {

  my (@new, @changed, @new_and_changed);

  # find new or updated project files
  say "\nChecking for new or changed project files" or croak;
  for my $install_file_obj ($self->_install_files) {
    my $install_fp_obj = $install_file_obj->install_file_path;
    my $install_fp     = $install_fp_obj->canonpath;
    my $stow_fp_obj    = $install_file_obj->stow_file_path;
    my $stow_fp        = $stow_fp_obj->canonpath;
    if ($install_fp_obj->is_file) {
      my $file_compare = File::Compare::compare($install_fp, $stow_fp);
      if ($file_compare == $FILE_COMP_ERROR) {
        my $msg = "Fatal error comparing $install_fp and $stow_fp";
        $self->vim_print($ERROR, $msg);
        die "Aborting\n";
      }
      elsif ($file_compare == 1) {
        push @changed, $install_file_obj;
      }
    }
    else {
      push @new, $install_file_obj;
    }
  }
  push @new_and_changed, @new, @changed;

  # nothing to do if no new or changed install files
  if (not @new_and_changed) {
    say "\nNo new or changed project files to install" or croak;
    say 'Update is complete'                           or croak;
    return $FALSE;
  }

  # report on files to update
  if (@new) {
    my $tpl = 'New project file(s) to install:';
    my $msg = $self->pluralise($tpl, scalar @new);
    $self->vim_print($WARNING, "\n$msg");
    for my $install_file_obj (@new) {
      my $fp = $install_file_obj->install_file_path->canonpath;
      $self->vim_print($WARNING, "• $fp");
    }
  }
  if (@changed) {
    my $tpl = '(This|These) project file(s) (is|are) changed:';
    my $msg = $self->pluralise($tpl, scalar @changed);
    $self->vim_print($WARNING, "\n$msg");
    for my $install_file_obj (@changed) {
      my $fp = $install_file_obj->install_file_path->canonpath;
      $self->vim_print($WARNING, "• $fp");
    }
  }

  # copy new and changed project files
  $self->_copy_files(@new_and_changed);

  return $FALSE;
}

# _validate_config_data($data)    {{{1
#
# does:   validate config data
# params: $data - extracted config data [hash, required]
# prints: feedback
# return: n/a, dies on invalid data
sub _validate_config_data ($self, $data) {

  # assume data structure looks like this
  # • note placeholders HOME, INSTALL_DIR and STOW_PKG_DIR
  #   which are replaced using $self->_replace_placeholders()
  #
  # {
  #   "repo" : {
  #     "clone_url" : "https://github.com/wofr06/lesspipe.git"
  #   },
  #   "stow" : {
  #     "root" : "HOME/.config/dotfiles",
  #     "pkg" : "lesspipe.sh",
  #     "extra" : [ "STOW_PKG_DIR/.config/zshenv.d/lesspipe.sh.zsh", ... ],
  #   },
  #   "install" : {
  #     "filepath_maps" : [
  #       [ "INSTALL_DIR/subdir/file",
  #         "STOW_PKG_DIR/subdir/file"
  #       ],
  #       ...,
  #     ],
  #     "substitutions" : [
  #       [ "INSTALL_DIR/libexec/lpipe", "HOME/.local/libexec/lpipe" ],
  #       ...,
  #     ],
  #   },
  # }

  ## no critic (ProhibitDuplicateLiteral ProhibitInterpolationOfLiterals RequireInterpolationOfMetachars)
  my $schema = {

    '$schema'   => 'https://json-schema.org/draft/2019-09/schema',
    title       => 'dn-lesspipe-update config file schema',
    description => 'validate data from the dn-lesspipe-update config file',

    # definitions
    '$defs' => {
      url => {
        description => 'model a complete url, requires url scheme',
        type        => 'string',
        format      => 'uri',
        pattern     => '^(https?|http?)://',
        minLength   => 10,
        maxLength   => 2000,
      },
      pair => {
        description     => 'array with 2 string items',
        type            => 'array',
        items           => [ { type => 'string' }, { type => 'string' } ],
        minItems        => 2,
        maxItems        => 2,
        additionalItems => $FALSE,
      },
    },
    type       => 'object',
    required   => [ 'repo', 'stow', 'install' ],
    properties => {

      # /repo
      repo => {
        type       => 'object',
        required   => ['clone_url'],
        properties => {

          # /repo/clone_url
          clone_url => {
            description => q{url of lesspipe's (github) repository},
            '$ref'      => '#/$defs/url'
          }
        },
        additionalProperties => $FALSE,
      },

      # /stow
      stow => {
        type       => 'object',
        required   => [ 'root', 'pkg', 'extra' ],
        properties => {

          # /stow/root
          root => {
            description => 'root directory for stow packages',
            type        => 'string'
          },

          # /stow/pkg
          pkg => {
            description => 'name of stow package holding lesspipe files',
            type        => 'string'
          },

          # /stow/extra
          extra => {
            description => 'files added by user, not part of lesspipe repo',
            type        => 'array',
            items       => { type => 'string' }
          },
        },
        additionalProperties => $FALSE,
      },

      # /install
      install => {
        type       => 'object',
        required   => [ 'filepath_maps', 'substitutions' ],
        properties => {

          # /install/filepath_maps
          filepath_maps => {
            description => 'install filepaths and related stow filepaths',
            type        => 'array',
            items       => { '$ref' => '#/$defs/pair' },
          },

          # /install/substitutions
          substitutions => {
            description => 'strings to match and replace in repo files',
            type        => 'array',
            items       => { '$ref' => '#/$defs/pair' },
          },
        },
        additionalProperties => $FALSE,
      },
    },
    additionalProperties => $FALSE,
  };
  ## use critic

  my $validator = JSON::Validator::Schema::Draft201909->new($schema);
  my @errors    = $validator->validate($data);

  if (@errors) {
    my $tpl = 'Config file data error(s) detected:';
    my $msg = $self->pluralise($tpl, scalar @errors);
    $self->vim_print($ERROR, "\n$msg");
    for my $error (@errors) { $self->vim_print($ERROR, "• $error"); }
    die "\nAborting\n";
  }

  return $FALSE;
}    # }}}1

1;

# POD    {{{1
__END__

=encoding utf8

=head1 NAME

App::Dn::LesspipeUpdate::Update - update a local lesspipe.sh installation

=head1 VERSION

This documentation is for App::Dn::LesspipeUpdate::Update version 0.1.

=head1 SYNOPSIS

    use strictures 2;
    use 5.006;
    use 5.038_001;
    use namespace::clean;
    use App::Dn::LesspipeUpdate::Update;

    App::Dn::LesspipeUpdate::Update->new_with_options->run;

=head1 DESCRIPTION

This module updates a local installation of the S<< F<lesspipe.sh> >>
preprocessor for F<less>. The preprocessor is available from the github
repository L<wofr06/lesspipe|https://github.com/wofr06/lesspipe>.

It is assumed the lesspipe.sh project files are installed via a F<stow>
package. The structure of the stow package at time of writing is:

    ├── .bash_completion
    │   └── less
    ├── .config
    │   ├── zshenv.d
    │   │   └── lesspipe.sh.zsh [EXTRA]
    │   └── zshrc.d
    │       └── 80-options-lessopen.sh.zsh [EXTRA]
    └── .local
        ├── bin
        │   ├── archive_color
        │   └── lesspipe.sh
        ├── libexec
        │   └── lesspipe
        │       └── lesscomplete
        └── share
            ├── man
            │   └── man1
            │       ├── archive_color.1 [EXTRA]
            │       ├── lesscomplete.1 [EXTRA]
            │       └── lesspipe.sh.1
            └── zsh
                └── completions
                    └── _less

File marked "[EXTRA]" were added to the stow package by this module's creator.
All other files are provided by the lesspipe.sh project.

=head2 Update process

The update process consists of the following steps:

=over

=item 1.

download the lesspipe.sh project to a temporary directory

=item 2.

build the project files in another temporary directory

=item 3.

perform substitutions on file content

=item 4.

copy build files to the stow package, renaming where necessary.

=back

The temporary directories are automatically deleted.

Over time the files contained in the lesspipe.sh project change, as can their
name and subdirectory location. Rather than encode this information into this
module, it is captured in a configuration file. See
L</CONFIGURATION AND ENVIRONMENT> below for details.

The module performs checks on the project build files at attempts it identify
any changes that have occurred since the previous update. If changes are
detected, they are reported to the user who decides whether to proceed with
updating the stow package.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Options

=head3 B<-b>  B<--build_only>

Download and build only. Does not install project files into the stow package.
Default: false.

=head3 B<-t>  B<--tests>

Run tests during the project build. Default: false.

Note: At the time of writing the build tests fail on linux systems, halting
indefinitely on S<test 67>: xlsx (neu).

=head2 Properties/attributes

No public properties/attributes.

=head2 Configuration file

The module looks for a configuration file with the base name
F<dn-lesspipe-update> in the standard configuration locations. Supported file
formats include ini, json, xml, and yaml. The file extension should match the
file format, for example, F<.json> for json formatted files. Warning: only the
json format has been thoroughly tested with this module.

The easiest way to show the configuration file format is with an example, in
this case in json format:

    {
      "repo": {
        "clone_url": "<lesspipe-github-project-url>"
      },
      "stow": {
        "root": "<path-to-stow-root-dir>",
        "pkg": "<name-of-lesspipe-stow-package-root-directory>",
        "extra": [ "<file-path>", ... ]
      },
      "install": {
        "filepath_maps": [
          [ "<path-to-install-file>", "<path-to-same-file-in-stow-package>" ],
          ...
        ],
        "substitutions": [
          ["<string-to-match>", "<replacement-string>"],
          ...
        ]
      }
    }

The following placeholders can be used in configuration file values:

=over

=item *

HOME

The current user's home directory path.

Used in:

=over

=item *

S<stow → root>

=item *

S<install → substitutions> S<→ replacement-string>

=back

=item *

STOW_PKG_DIR

The stow package root directory. This is obtained by joining the values from
S<stow → root> and S<stow → pkg>.

Used in:

=over

=item *

S<stow → extra>

=item *

S<install → filepath_maps> S<→ mapped-stow-file>

=back

=item *

INSTALL_DIR

The temporary directory used by the module to install/build the project files.

Used in:

=over

=item *

S<install → filepath_maps> S<→ install-file-path>

=item *

S<install → substitutions> S<→ match-string>

=back

=back

=head3 Environment variables

None used.

=head1 SUBROUTINES/METHODS

=head2 run()

Main module method. Performs the tasks described in the L<DESCRIPTION> section.

=head3 Params

None.

=head3 Prints

Feedback and messages as required.

=head3 Returns

N/A. Dies on failure.

=head1 DIAGNOSTICS

=head2 Expected config data HASH, got: VAR_TYPE

=head2 Expected KEY value to be TYPE, got TYPE

=head2 Expected KEY->SUBKEY value to be TYPE, got TYPE

=head2 Invalid primary key KEY

=head2 Invalid key KEY->SUBKEY

=head2 No config file key: KEY

=head2 No config file key: KEY->SUBKEY

=head2 Expected array with 1 element, got NUM

=head2 Expected TYPE, got: TYPE

=head2 No config section named NAME

=head2 No key named NAME in section NAME

These errors occur when the configuration file is being read and the data is
in an unexpected format.

=head2 Copying current project files into stow package ... ERROR

This occurs when a file copy fails. The most likely cause is that the target
stow package subdirectory does not exist.

=head2 INSTALL_DIR not set

=head2 STOW_ROOT not set

=head2 STOW_PKG not set

These errors occur if values for any of these placeholders are not set. These
errors should not occur as earlier errors should have halted processing before
these errors are generated.

=head2 No configuration files located

Occurs if none of the combinations of candidate configuration directories,
file stem, and suffixes result in a locatable filepath.

=head2 No stem name provided

Occurs if no configuration file base name is available.

=head2 Slurp failed

This error occurs during an attempt to perform a search and replace on build
files. If the operating system provided an error message it will be displayed
as well.

=head2 There are no loaders available for .EXT files

The file format inferred from the configuration file extension is not
supported.

=head2 These expected extra files are missing: FILES

=head2 These expected install files are missing from the build: FILES

=head2 These install files were not expected: FILES

=head2 These expected stow files are missing from the stow package: FILES

=head2 These stow package files were not expected: FILES

These warning messages are displayed when the module detects changes between
the newly downloaded project files and those project files defined in the
configuration and present in the stow package.

=head2 Unable to generate list of candidate configuration directories

Occurs if the module is unable to generate any candidate configuration
directories.

=head2 Write failed

This error occurs during an attempt to perform a search and replace on build
files. If the operating system provided an error message it will be displayed
as well.

=head1 INCOMPATIBILITIES

None known.

=head1 DEPENDENCIES

=head2 Perl modules

App::Dn::LesspipeUpdate::InstallFile, App::Dn::LesspipeUpdate::Substitution,
Carp, Const::Fast, English, Env, Feature::Compat::Try, File::Copy, File::chdir,
Git::Repository, List::SomeUtils, Moo, MooX::HandlesVia, MooX::Options,
namespace::clean, Path::Tiny, Role::Utils::Dn, strictures, Types::Path::Tiny,
Types::Standard, URI, version.

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
