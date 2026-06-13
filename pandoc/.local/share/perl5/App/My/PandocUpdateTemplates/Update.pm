package App::My::PandocUpdateTemplates::Update;

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
use App::My::PandocUpdateTemplates::FilepathMapping;
use App::My::PandocUpdateTemplates::Repository;
use App::My::PandocUpdateTemplates::Substitution;
use Archive::Tar;
use Carp qw(croak);
use Const::Fast;
use English;
use Env qw($HOME);
use Feature::Compat::Try;
use File::chdir;
use File::Copy;
use File::Fetch;
use Git::Repository;
use JSON::Validator::Schema::Draft201909;
use MooX::HandlesVia;
use MooX::Options (
  authors      => 'David Nebauer <david at nebauer dot org>',
  description  => 'Update stow package of pandoc templates',
  protect_argv => 0,
);
use Path::Tiny;
use Types::Standard;
use URI;

with qw(Role::Utils::Dn);

const my $TRUE             => 1;
const my $FALSE            => 0;
const my $WARNING          => 'warning';
const my $ERROR            => 'error';
const my $ERROR_SHIFT      => 8;
const my $MOD_PATH_TINY    => 'Path::Tiny';
const my $PROCEED_QUESTION => 'Proceed with update?';    # }}}1

# options

# repository (-r)    {{{1
option 'repository' => (
  is      => 'rw',
  short   => 'r',
  format  => 's@',
  default => sub { [] },
  doc     => 'Repository to update (multiple allowed)',
);

# show_config_data (-c)    {{{1
option 'show_config_data' => (
  is    => 'ro',
  short => 'c',
  doc   => 'Show configuration data and exit',
);

# attributes

# _repos, _add_repo    {{{1
has '_repos_array' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf [
      'App::My::PandocUpdateTemplates::Repository'],
  ],
  required    => $TRUE,
  default     => sub { [] },
  handles_via => 'Array',
  handles     => {
    _repos    => 'elements',
    _add_repo => 'push',
  },
  doc => 'Array of repository objects',
);

# _stow_templates_dir    {{{1
has '_stow_templates_dir' => (
  is       => 'rw',
  isa      => Types::Standard::InstanceOf [$MOD_PATH_TINY],
  required => $FALSE,
  coerce   => $TRUE,
  doc      => 'Pandoc templates directory in stow package',
);

# _stow_extras, _load_stow_extras    {{{1
has '_stow_extra_array' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf [$MOD_PATH_TINY],
  ],
  required    => $TRUE,
  default     => sub { [] },
  handles_via => 'Array',
  handles     => {
    _stow_extras      => 'elements',
    _load_stow_extras => 'push',
  },
  doc => 'Files in stow package templates dir not from repos',
);

# _stow_template_files, _load_stow_template_files    {{{1
has '_stow_template_files_array' => (
  is  => 'rw',
  isa => Types::Standard::ArrayRef [
    Types::Standard::InstanceOf [$MOD_PATH_TINY],
  ],
  required    => $TRUE,
  default     => sub { [] },
  handles_via => 'Array',
  handles     => {
    _stow_template_files      => 'elements',
    _load_stow_template_files => 'push',
  },
  doc => 'Files in stow package templates dir',
);

# _config_schema    {{{1
has '_config_schema' => (
  is  => 'lazy',
  isa => Types::Standard::HashRef,
  doc => 'JSON schema used by configuration file data',
);

sub _build__config_schema ($self) {    ## no critic (ProhibitUnusedPrivateSubroutines)

  # assume data structure looks like this
  # • note placeholders HOME, DOWNLOAD_ROOT and STOW_TEMPLATES_DIR
  #   which are replaced using $self->_replace_placeholders()
  # • repo properties "release-path-extraction-regex" and "asset-type" are
  #   required only if "obtain-method" is set to "download-release-asset"
  #
  # {
  #   "repos" : [
  #     {
  #       "name" : "buttondown",
  #       "description" : "fork of ryangray/buttondown repo",
  #       "download-url" : "https://github.com/dnebauer/buttondown.git",
  #       "asset-type" : "targz",
  #       "obtain-method" : "git-clone-repository",
  #       //                or "download-release-asset"
  #       "release-path-extraction-regex" : "<regex-string>",
  #       "filepath-mappings" : [
  #         [
  #           "DOWNLOAD_ROOT/buttondown.css",
  #           "STOW_TEMPLATES_DIR/buttondown.css"
  #         ],
  #         ...,
  #       ],
  #       "delete-after-download" : [
  #         "DOWNLOAD_ROOT/pandoc_example.bat",
  #         ...,
  #       ],
  #       "ignore" : [
  #         "DOWNLOAD_ROOT/LICENSE.md",
  #         ...,
  #       ],
  #       "substitutions" : []
  #     },
  #     ...,
  #   ],
  #   "stow" : {
  #     "template-dir" : "HOME/.../pandoc/templates",
  #     "extra" : [],
  #   }
  # }

  ## no critic (ProhibitDuplicateLiteral ProhibitInterpolationOfLiterals RequireInterpolationOfMetachars)
  my $schema = {

    '$schema'   => 'https://json-schema.org/draft/2019-09/schema',
    title       => 'pandoc-my-update-templates config file schema',
    description => 'validate data from the configuration file',

    # definitions
    '$defs' => {

      #/$defs/url
      url => {
        type        => 'string',
        description => 'model a complete url, requires url scheme',
        format      => 'uri',
        pattern     => '^(https?|http?)://',
        minLength   => 10,
        maxLength   => 2000,
      },

      #/$defs/pair
      pair => {
        type            => 'array',
        description     => 'array with 2 string items',
        items           => [ { type => 'string' }, { type => 'string' } ],
        minItems        => 2,
        maxItems        => 2,
        additionalItems => $FALSE,
      },

      #/$defs/repo
      repo => {
        type        => 'object',
        description => 'a github repository',
        required    => [
          'name',                  'download-url',
          'obtain-method',         'filepath-mappings',
          'delete-after-download', 'ignore',
          'substitutions'
        ],

        if => {
          properties =>
              { 'obtain-method' => { const => 'download-release-asset' } },
          required => ['obtain-method'],
        },
        then => {
          required => [ 'asset-type', 'release-path-extraction-regex' ]
        },
        else => {
          not => {
            anyOf => [
              { required => ['asset-type'] },
              { required => ['release-path-extraction-regex'] },
            ],
          },
        },

        properties => {
          name => {
            type        => 'string',
            description => 'human-readable repo name',
          },
          description => {
            type        => 'string',
            description => 'human-readable description of repo',
          },
          'download-url' => {
            '$ref'      => '#/$defs/url',
            description => 'download url (for cloning or release file)',
          },
          'asset-type' => {
            type        => 'string',
            description => 'file type (guide for extraction command)',
            enum        => ['targz'],
          },
          'obtain-method' => {
            type        => 'string',
            description => 'how repo is obtained',
            enum => [ 'git-clone-repository', 'download-release-asset' ],
          },
          'release-path-extraction-regex' => {
            type        => 'string',
            description => 'regex to extract release path from repo path',
          },
          'filepath-mappings' => {
            type        => 'array',
            description => 'pair of repo file and matching stow file',
            items       => { '$ref' => '#/$defs/pair' },
          },
          'delete-after-download' => {
            type        => 'array',
            description => 'delete these files/dirs after download',
            items       => { type => 'string' }
          },
          ignore => {
            type        => 'array',
            description => 'repo files not copied to stow package',
            items       => { type => 'string' }
          },
          substitutions => {
            type        => 'array',
            description => 'strings to match and replace in repo files',
            items       => { '$ref' => '#/$defs/pair' },
          },
        },
        additionalProperties => $FALSE,
      },
    },

    type       => 'object',
    required   => [ 'repos', 'stow' ],
    properties => {

      # /repos
      repos => {
        type                 => 'array',
        description          => 'repositories to download',
        items                => { '$ref' => '#/$defs/repo' },
        minItems             => 1,
        additionalProperties => $FALSE,
      },

      # /stow
      stow => {
        type       => 'object',
        required   => [ 'template-dir', 'extra' ],
        properties => {

          # /stow/root
          'template-dir' => {
            type        => 'string',
            description => 'templates directory within stow package',
          },

          # /stow/extra
          extra => {
            type        => 'array',
            description => 'files added by user, not part of repos',
            items       => { type => 'string' },
          },
        },
        additionalProperties => $FALSE,
      },
    },
    additionalProperties => $FALSE,
  };
  ## use critic
  return $schema;
}    # }}}1

# methods

# run()    {{{1
#
# does:   main method
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub run ($self) {

  # load configuration data
  $self->_load_from_config_file;
  if ($self->show_config_data) {
    $self->_print_config_data;
    return $FALSE;
  }

  # download configured repos
  $self->_prune_repos;
  $self->_download_repos;
  $self->_amend_file_lists;
  $self->_delete_paths_after_download;
  $self->_set_file_lists;

  # check whether project has changed filepaths
  # • changes displayed to user
  if ($self->_structural_project_changes) {
    say q{} or croak;
    if (not $self->interact_confirm($PROCEED_QUESTION)) {
      return $FALSE;
    }
  }

  # perform file substitutions
  $self->_do_file_content_substitutions;

  # identify new and changed repo files
  if (not $self->_identify_updated_files) {
    say "\nNo new or changed project files to install" or croak;
    say 'Update is complete'                           or croak;
    return $FALSE;
  }

  # update stow package files
  say q{} or croak;
  if (not $self->interact_confirm($PROCEED_QUESTION)) {
    say 'Aborting update' or croak;
    return $FALSE;
  }
  $self->_update_files;

  return $FALSE;
}

# _amend_file_lists()    {{{1
#
# does:   replace RELEASE_PATH tokens in 'delete', ignore' and
#         'filepath-mapping' file lists in 'download-release-asset'-type repos
# params: nil
# prints: feedback on error
# return: n/a, dies on failure
sub _amend_file_lists ($self) {
  say 'Amending repo file lists' or croak;

  for my $repo ($self->_repos) {

    # adjust file lists for 'download-release-asset'-type repos
    if ($repo->obtain_method eq 'download-release-asset') {    ## no critic (ProhibitDuplicateLiteral)

      my ($name, $download_dir) = ($repo->name, $repo->download_dir);
      my @fps = $self->file_list_recursively($download_dir);

      # • get replacement string for RELEASE_PATH token
      my $re = $repo->release_path_extraction_regex;
      my $fp = $fps[0];
      $fp =~ $re or croak "Can't extract release-path from repo '$name'";
      my $release_path = join q{}, @{^CAPTURE};    ## no critic (ProhibitPunctuationVars)

      # • replace token in delete-paths
      my @delete_paths =
          map { Path::Tiny::path($_) }
          map {s/RELEASE_PATH/$release_path/xsmgr}
          map { $_->canonpath } @{ $repo->delete_paths };
      $repo->delete_paths([@delete_paths]);

      # • replace token in ignore-files
      my @ignore_files =
          map { Path::Tiny::path($_) }
          map {s/RELEASE_PATH/$release_path/xsmgr}
          map { $_->canonpath } @{ $repo->ignore_files };
      $repo->ignore_files([@ignore_files]);

      # • replace token in filepath-mappings downloaded files
      my @filepath_mappings;
      for my $filepath_mapping (@{ $repo->filepath_mappings }) {
        my ($downloaded_file, $mapped_file) = (
          $filepath_mapping->downloaded_file_path,
          $filepath_mapping->stow_file_path
        );
        $downloaded_file =~ s/RELEASE_PATH/$release_path/xsmg;
        my $replacement_mapping =
            App::My::PandocUpdateTemplates::FilepathMapping->new(
          downloaded_file_path => Path::Tiny::path($downloaded_file),
          stow_file_path       => Path::Tiny::path($mapped_file),
            );
        push @filepath_mappings, $replacement_mapping;
      }
      $repo->filepath_mappings([@filepath_mappings]);
    }
  }

  return $FALSE;
}

# _delete_paths_after_download()    {{{1
#
# does:   delete specified files and directories after download
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub _delete_paths_after_download ($self) {

  my $abort = $FALSE;

  for my $repo ($self->_repos) {
    my $printed_header = $FALSE;
    my ($name, $dir, @delete_paths) =
        ($repo->name, $repo->download_dir, @{ $repo->delete_paths });
    for my $delete_path (@delete_paths) {
      my $delete_fp = $delete_path->canonpath;
      $delete_fp =~ s/$dir/DOWNLOAD_DIR/xsmg;
      if ($delete_path->is_file) {
        $delete_path->remove
            or croak "Unable to delete: ($name)$delete_fp: $OS_ERROR";
      }
      elsif ($delete_path->is_dir) {
        my $opts = { safe => $FALSE };
        $delete_path->remove_tree($opts)
            or croak "Unable to delete: ($name)$delete_fp: $OS_ERROR";
      }
      else {
        croak "Not a file or directory: ($name)$delete_fp";
      }
    }
  }
  return $FALSE;
}

# _do_file_content_substitutions()    {{{1
#
# does:   perform substitutions on built files
# params: nil
# prints: feedback
# return: n/a
sub _do_file_content_substitutions ($self) {

  my $printed_feedback = $FALSE;

  for my $repo ($self->_repos) {
    my $name = $repo->name;
    my $dir  = $repo->download_dir->canonpath;
    my @fps  = map { $_->downloaded_file_path } @{ $repo->filepath_mappings };
    my @subs = @{ $repo->substitutions };

    # need both files and substitutions to proceed
    next if not @fps;
    next if not @subs;

    for my $fp (@fps) {
      next if not $fp->is_file;
      my $fpath      = $fp->canonpath;
      my $show_fpath = $fpath =~ s/$dir/DOWNLOAD_DIR/xsmrg;
      my $data;
      try {
        $data = $fp->slurp_utf8;
      }
      catch ($err) {
        if   ($err) { $self->vim_print($ERROR, "Slurp failed: $err"); }
        else        { $self->vim_print($ERROR, "Slurp failed: $fpath"); }
      }
      my $printed_fp = $FALSE;
      for my $sub (@subs) {
        my ($pattern, $replace) = ($sub->pattern, $sub->replacement);
        my $count = $data =~ s/$pattern/$replace/xsmg;    # Do NOT add /r
        if ($count) {
          if (not $printed_feedback) {
            $printed_feedback = $TRUE;
            say "\nPerforming file text substitutions:" or croak;
          }
          if (not $printed_fp) {
            $printed_fp = $TRUE;
            say "\n• ($name)$show_fpath" or croak;
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
  }

  if ($printed_feedback) {
    say "\nSubstitutions done" or croak;
  }

  return $FALSE;
}

# _download_repos()    {{{1
#
# does:   download online github repos to build directory
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub _download_repos ($self) {    ## no critic (ProhibitExcessComplexity)

  my $divider_top    = $self->divider;
  my $divider_bottom = $divider_top =~ s/-/=/xsmgr;

  for my $repo ($self->_repos) {
    my ($name, $url, $obtain_method, $dir) = (
      $repo->name,          $repo->download_url->as_string,
      $repo->obtain_method, $repo->download_dir->canonpath,
    );
    ## no critic (ProhibitDuplicateLiteral)
    if ($obtain_method eq 'git-clone-repository') {
      my $opt = { fatal => '!0' };    # make exit codes 1-255 fatal
      say "Cloning '$name' repo" or croak;
      say $divider_top           or croak;
      Git::Repository->run(clone => $url, $dir, $opt);
      my $err_code = $CHILD_ERROR >> $ERROR_SHIFT;
      say $divider_bottom or croak;
      if ($err_code != 0) {
        croak "Clone failed with error code: $err_code";
      }
    }
    elsif ($obtain_method eq 'download-release-asset') {
      my $fetcher = File::Fetch->new(uri => $url);
      say "Downloading release asset for '$name' repo" or croak;
      say $divider_top                                 or croak;
      my $filepath = $fetcher->fetch(to => $dir) or croak $fetcher->error;
      my ($asset_type, $release_path_extraction_regex) =
          ($repo->asset_type, $repo->release_path_extraction_regex);
      if ($asset_type eq 'targz') {
        my $tar = Archive::Tar->new;
        say 'Extracting contents of release asset' or croak;
        $tar->read($filepath)                      or croak $tar->error;
        {
          local $File::chdir::CWD = $dir;
          $tar->extract or croak $tar->error;
        }
        unlink $filepath
            or croak "Unable to delete asset release file: $OS_ERROR";
      }
      else {
        croak "Invalid asset-type: '$asset_type'";
      }
      say $divider_bottom or croak;
    }
    else {
      croak "Invalid obtain-method: '$obtain_method'";
    }
    ## use critic

    # delete any .git directory
    my $git_dir_fp = $self->path_join($dir, '.git');
    my $git_dir    = Path::Tiny::path($git_dir_fp);
    if ($git_dir->is_dir) {
      my $opts = { safe => $FALSE };
      $git_dir->remove_tree($opts)
          or croak "Unable to delete .git dir: $OS_ERROR";
    }

  }
  return $FALSE;
}

# _identify_updated_files()    {{{1
#
# does:   identify new and changed files from each repo
# params: nil
# prints: feedback
# return: boolean, whether updatable files found
sub _identify_updated_files ($self) {

  my @updated;

  # find new or updated project files
  say "\nChecking for new or changed project files" or croak;
  for my $repo ($self->_repos) {
    my (@repo_new, @repo_changed, @repo_new_and_changed);
    for my $filepath_mapping (@{ $repo->filepath_mappings }) {
      my $downloaded_fp_obj = $filepath_mapping->downloaded_file_path;
      my $downloaded_fp     = $downloaded_fp_obj->canonpath;
      my $stow_fp_obj       = $filepath_mapping->stow_file_path;
      my $stow_fp           = $stow_fp_obj->canonpath;
      if ($stow_fp_obj->is_file) {
        if (not $self->file_identical($downloaded_fp, $stow_fp)) {
          push @repo_changed, $filepath_mapping;
        }
      }
      else {
        push @repo_new, $filepath_mapping;
      }
    }
    push @repo_new_and_changed, @repo_new, @repo_changed;
    if (@repo_new_and_changed) {
      my ($name, $download_dir) =
          ($repo->name, $repo->download_dir->canonpath);
      my @repo_feedback;
      if (@repo_new) {
        my $tpl = '    New file(s) to install:';
        my $msg = $self->pluralise($tpl, scalar @repo_new);
        push @repo_feedback, $msg;
        for my $filepath_mapping (@repo_new) {
          my $fp = $filepath_mapping->downloaded_file_path->canonpath;
          $fp =~ s/$download_dir/DOWNLOAD_DIR/xsmg;
          push @repo_feedback, "    • $fp";
        }
      }
      if (@repo_changed) {
        my $tpl = '    (This|These) project file(s) (is|are) changed:';
        my $msg = $self->pluralise($tpl, scalar @repo_changed);
        push @repo_feedback, $msg;
        for my $filepath_mapping (@repo_changed) {
          my $fp = $filepath_mapping->downloaded_file_path->canonpath;
          $fp =~ s/$download_dir/DOWNLOAD_DIR/xsmg;
          push @repo_feedback, "    • $fp";
        }
      }
      say "\n  Repo '$name':" or croak;
      for my $msg (@repo_feedback) {
        $self->vim_print($WARNING, $msg);
      }
    }
    $repo->updated_files([@repo_new_and_changed]);
    push @updated, @repo_new_and_changed;
  }

  my $found_updatable_files = (@updated) ? $TRUE : $FALSE;

  return $found_updatable_files;
}

# _load_from_config_file()    {{{1
#
# does:   load attributes from config file
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub _load_from_config_file ($self) {

  # load config file data
  my $conf = $self->config_file('pandoc-my-update-templates');
  my $data = $conf->data;

  # check integrity of config data (dies on failure)
  $self->_validate_config_data($data);

  # assume data structure looks like this
  # • note placeholders HOME, DOWNLOAD_ROOT and STOW_TEMPLATES_DIR
  #   which are replaced using $self->_replace_placeholders()
  # • repo properties "release-path-extraction-regex" and "asset-type" are
  #   required only if "obtain-method" is set to "download-release-asset"
  #
  # {
  #   "repos" : [
  #     {
  #       "name" : "buttondown",
  #       "description" : "fork of ryangray/buttondown repo",
  #       "download-url" : "https://github.com/dnebauer/buttondown.git",
  #       "asset-type" : "targz",
  #       "obtain-method" : "git-clone-repository",
  #       //                or "download-release-asset"
  #       "release-path-extraction-regex" : "<regex-string>",
  #       "filepath-mappings" : [
  #         [
  #           "DOWNLOAD_ROOT/buttondown.css",
  #           "STOW_TEMPLATES_DIR/buttondown.css"
  #         ],
  #         ...,
  #       ],
  #       "ignore" : [
  #         "DOWNLOAD_ROOT/LICENSE.md",
  #         ...,
  #       ],
  #       "substitutions" : []
  #     },
  #     ...,
  #   ],
  #   "stow" : {
  #     "template-dir" : "HOME/.../pandoc/templates",
  #     "extra" : [],
  #   }
  # }

  # set attributes

  ## no critic (ProhibitDuplicateLiteral)
  # • _stow_templates_dir, _stow_extras
  my $stow_data = $data->{'stow'};
  $self->_replace_placeholders($stow_data);
  my $templates_dir = Path::Tiny::path($stow_data->{'template-dir'});
  $self->_stow_templates_dir($templates_dir);
  my @stow_extras = map { Path::Tiny::path($_) } @{ $stow_data->{'extra'} };
  $self->_load_stow_extras(@stow_extras);

  # • _repos
  my $repos_data = $data->{'repos'};
  for my $repo_data (@{$repos_data}) {
    my $download_dir = Path::Tiny->tempdir(TEMPLATE => 'tmp-XXXXXXXX');
    $self->_replace_placeholders($repo_data, $download_dir);
    my ($name, $description, $download_url, $obtain_method) = (
      $repo_data->{'name'},         $repo_data->{'description'},
      $repo_data->{'download-url'}, $repo_data->{'obtain-method'},
    );
    my @filepath_mappings =
        map {
      App::My::PandocUpdateTemplates::FilepathMapping->new(
        downloaded_file_path => $_->[0],
        stow_file_path       => $_->[1]
      )
        } @{ $repo_data->{'filepath-mappings'} };
    my @delete = map { Path::Tiny::path($_) }
        @{ $repo_data->{'delete-after-download'} };
    my @ignore = map { Path::Tiny::path($_) } @{ $repo_data->{'ignore'} };
    my @substitutions = map {
      App::My::PandocUpdateTemplates::Substitution->new(
        pattern     => $_->[0],
        replacement => $_->[1]
      )
    } @{ $repo_data->{'substitutions'} };
    my ($asset_type, $release_path_extraction_regex) = (undef, undef);
    if ($obtain_method eq 'download-release-asset') {
      $asset_type = $repo_data->{'asset-type'};
      my $regex_string = $repo_data->{'release-path-extraction-regex'};
      $release_path_extraction_regex = qr{$regex_string}xsmp;
    }
    my $repo = App::My::PandocUpdateTemplates::Repository->new(
      download_dir                  => $download_dir,
      name                          => $name,
      description                   => $description,
      download_url                  => URI->new($download_url),
      asset_type                    => $asset_type,
      obtain_method                 => $obtain_method,
      release_path_extraction_regex => $release_path_extraction_regex,
      filepath_mappings             => [@filepath_mappings],
      delete_paths                  => [@delete],
      ignore_files                  => [@ignore],
      substitutions                 => [@substitutions],
    );
    $self->_add_repo($repo);
  }

  return $FALSE;
}

# _print_config_data()    {{{1
#
# does:   print configuration file data
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub _print_config_data ($self) {
  my $stow_templates_dir = $self->_stow_templates_dir;
  say "Stow templates dir: $stow_templates_dir" or croak;
  say 'Repositories:'                           or croak;
  for my $repo ($self->_repos) {
    my ($name, $description, $url) =
        ($repo->name, $repo->description, $repo->download_url);
    say "  $name [$description]" or croak;
    say "    -> $url"            or croak;
  }
  return $FALSE;
}

# _prune_repos()    {{{1
#
# does:   if user specified repos, remove non-specified repos
#         checks validity of specified repo names and dies if any detected
# params: nil
# prints: feedback
# return: n/a, dies on failure
sub _prune_repos ($self) {

  # if no repositories specified then keep all of them
  my @specified_repos = @{ $self->repository };
  if (not @specified_repos) { return $FALSE; }

  # check for invalid repository names
  # • die if any invalid repository names provided
  my %valid_repo_name = map { $_ => $TRUE } map { $_->name } $self->_repos;
  my @invalid_repo_names =
      grep { not exists $valid_repo_name{$_} } @specified_repos;
  if (@invalid_repo_names) {
    my $names = join ', ', @invalid_repo_names;
    my $tpl   = "Invalid repository name(s): $names";
    my $msg   = $self->pluralise($tpl, scalar @invalid_repo_names);
    $self->vim_print($ERROR, "\n$msg");
    die "Aborting\n";
  }

  # keep only specified repos
  my %all_repos = map { $_->name => $_ } $self->_repos;
  my @repos     = map { $all_repos{$_} } @specified_repos;
  $self->_repos_array([@repos]);

  return $FALSE;
}

# _replace_placeholders($data, $dir)    {{{1
#
# does:   replace config file placeholders in part of config file data
# params: $data - data structure whose values will be operated upon
#                 [hashref or arrayref, required]
#         $dir  - download root directory
#                 [Path::Tiny object, optional, default=undef]
# prints: feedback
# return: n/a, operates on $data by reference
# note:   this method handles placeholders:
#         HOME, DOWNLOAD_ROOT and STOW_TEMPLATES_DIR
# note:   only guaranteed to replace HOME,
#         replaces DOWNLOAD_ROOT if provided,
#         replaces STOW_TEMPLATES_DIR if it is set
sub _replace_placeholders ($self, $data, $dir = undef) {

  my $placeholder_values = { HOME => $HOME };

  if ($dir) {
    my $dir_ref = ref $dir;
    if ($dir_ref ne $MOD_PATH_TINY) {
      croak "Expected Path::Tiny directory object, got $dir_ref";
    }
    $placeholder_values->{'DOWNLOAD_ROOT'} = $dir->canonpath;
  }

  my $stow_templates_dir = $self->_stow_templates_dir;
  if ($stow_templates_dir) {
    $placeholder_values->{'STOW_TEMPLATES_DIR'} =
        $stow_templates_dir->canonpath;
  }

  $self->replace_tokens($data, $placeholder_values);

  return $FALSE;
}

# _set_file_lists()    {{{1
#
## does:   set lists for downloaded and stow template files
# does:   set lists for stow template files
# params: nil
# prints: feedback on error
# return: n/a, dies on failure
sub _set_file_lists ($self) {
  say 'Analysing repo file lists' or croak;

  ## add obtained-files list to each repo
  #for my $repo ($self->_repos) {
  #  my ($name, $download_dir) = ($repo->name, $repo->download_dir);
  #  my @fps      = $self->file_list_recursively($download_dir);
  #  my @obtained = map { Path::Tiny::path($_) } @fps;
  #  $repo->load_obtained_files(@obtained);
  #}

  # add stow template files list
  my $stow_templates_dir  = $self->_stow_templates_dir;
  my @fps                 = $self->file_list_recursively($stow_templates_dir);
  my @stow_template_files = map { Path::Tiny::path($_) } @fps;
  $self->_load_stow_template_files(@stow_template_files);

  return $FALSE;
}

# _structural_project_changes()    {{{1
#
# does:   check whether file names or locations have changed
# params: nil
# prints: feedback
# return: boolean (whether changes found)
sub _structural_project_changes ($self) {    ## no critic (ProhibitExcessComplexity)

  my $structure_change_detected = $FALSE;

  # key stow paths
  my $stow_templates_dir = $self->_stow_templates_dir->canonpath;
  my @stow_extra_and_actual_fps =
      map { $_->canonpath } $self->_stow_template_files;
  my @stow_extra_fps = map { $_->canonpath } $self->_stow_extras;
  my @stow_actual_fps =
      $self->subtract_array([@stow_extra_and_actual_fps], [@stow_extra_fps]);
  my @stow_expected_fps;

  for my $repo ($self->_repos) {
    my @repo_feedback;

    my ($name, $download_dir) = ($repo->name, $repo->download_dir->canonpath);

    # file lists to use
    my @repo_filepath_mappings = @{ $repo->filepath_mappings };
    my @repo_expected_fps      = map { $_->canonpath }
        map { $_->downloaded_file_path } @repo_filepath_mappings;
    my @repo_actual_and_ignore_fps =
        map { $_->canonpath } @{ $repo->obtained_files };
    my @repo_ignore_fps = map { $_->canonpath } @{ $repo->ignore_files };
    my @repo_actual_fps = $self->subtract_array([@repo_actual_and_ignore_fps],
      [@repo_ignore_fps]);
    my @repo_stow_fps = map { $_->canonpath }
        map { $_->stow_file_path } @repo_filepath_mappings;
    my %ignore_mapped_file = map { $_ => $TRUE } @repo_ignore_fps;

    # update expected stow file list
    push @stow_expected_fps, @repo_stow_fps;

    # check whether files have been added/removed
    my $cmp_repo_fps =
        $self->compare_arrays([@repo_expected_fps], [@repo_actual_fps]);
    if ($cmp_repo_fps->elements_added) {
      $structure_change_detected = $TRUE;
      my @added = $cmp_repo_fps->added_elements;
      my @fps   = map {s/^$download_dir/DOWNLOAD_DIR/xsmr} @added;
      my $tpl   = '(This|These) repo file(s) (was|were) not expected:';
      my $msg   = $self->pluralise($tpl, scalar @added);
      push @repo_feedback, "\n$msg";
      for my $fp (@fps) { push @repo_feedback, "• $fp"; }
    }
    if ($cmp_repo_fps->elements_removed) {
      $structure_change_detected = $TRUE;
      my @removed = $cmp_repo_fps->removed_elements;
      my @fps     = map {s/^$download_dir/DOWNLOAD_DIR/xsmr} @removed;
      my $tpl     = '(This|These) file(s) (is|are) missing:';
      my $msg     = $self->pluralise($tpl, scalar @removed);
      push @repo_feedback, "\n$msg";
      for my $fp (@fps) { push @repo_feedback, "• $fp"; }
    }
    if (@repo_feedback) {
      say "\nAnalysing '$name' repo structure" or croak;
      for my $msg (@repo_feedback) {
        $self->vim_print($WARNING, "$msg");
      }
    }
  }

  # check stow package only if processing all repos
  my @specified_repos = @{ $self->repository };
  if (not @specified_repos) {

    my @stow_feedback;

    # check that all extra-stow-fps are existing stow fps
    my @stow_missing_extra_fps =
        $self->compare_arrays([@stow_extra_fps], [@stow_extra_and_actual_fps])
        ->removed_elements;
    if (@stow_missing_extra_fps) {
      $structure_change_detected = $TRUE;
      my @fps =
          map {s/^$stow_templates_dir/STOW_TEMPLATES_DIR/xsmr}
          @stow_missing_extra_fps;
      my $tpl = '(This|These) expected stow extra file(s) (is|are) missing:';
      my $msg = $self->pluralise($tpl, scalar @stow_missing_extra_fps);
      push @stow_feedback, "\n$msg";
      for my $fp (@fps) { push @stow_feedback, "• $fp"; }
    }

    # compare expected and actual stow fps
    my $cmp_stow =
        $self->compare_arrays([@stow_expected_fps], [@stow_actual_fps]);
    if ($cmp_stow->elements_removed) {
      $structure_change_detected = $TRUE;
      my @removed =
          map {s/^$stow_templates_dir/STOW_TEMPLATES_DIR/xsmr}
          $cmp_stow->removed_elements;
      my $tpl = '(This|These) expected stow file(s) (is|are) '
          . 'missing from the stow package:';
      my $msg = $self->pluralise($tpl, scalar @removed);
      push @stow_feedback, "\n$msg";
      for my $file (@removed) { push @stow_feedback, "• $file"; }
    }
    if ($cmp_stow->elements_added) {
      $structure_change_detected = $TRUE;
      my @added =
          map {s/^$stow_templates_dir/STOW_TEMPLATES_DIR/xsmr}
          $cmp_stow->added_elements;
      my $tpl = '(This|These) stow package file(s) (was|were) not expected:';
      my $msg = $self->pluralise($tpl, scalar @added);
      push @stow_feedback, "\n$msg";
      for my $file (@added) { push @stow_feedback, "• $file"; }
    }

    if (@stow_feedback) {
      say "\nAnalysing stow package structure" or croak;
      for my $msg (@stow_feedback) {
        $self->vim_print($WARNING, "$msg");
      }
    }
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

# _update_files()    {{{1
#
# does:   copy new and changed project files into stow package
# params: nil
# prints: feedback
# return: n/a
sub _update_files ($self) {

  say "\nCopying updated files into stow package:" or croak;

  my $stow_templates_dir = $self->_stow_templates_dir;

  for my $repo ($self->_repos) {
    my ($name, $download_dir) = ($repo->name, $repo->download_dir->canonpath);
    for my $filepath_mapping (@{ $repo->updated_files }) {
      my ($downloaded_fp, $stow_fp) = (
        $filepath_mapping->downloaded_file_path->canonpath,
        $filepath_mapping->stow_file_path->canonpath
      );
      my $show_downloaded_fp =
          $downloaded_fp =~ s/$download_dir/DOWNLOAD_DIR/xsmrg;
      my $show_stow_fp =
          $stow_fp =~ s/$stow_templates_dir/STOW_TEMPLATES_DIR/xsmrg;
      say "\n• ($name)$show_downloaded_fp\n  -> $show_stow_fp" or croak;
      if (File::Copy::copy($downloaded_fp, $stow_fp)) {
        say '  -- copied' or croak;
      }
      else {
        $self->vim_print($ERROR, "  -- failed: $OS_ERROR");
      }
    }
  }
  say "\nCopying done" or croak;

  return $FALSE;
}

# _validate_config_data($data)    {{{1
#
# does:   validate config data
# params: $data - extracted config data [hash, required]
# prints: feedback
# return: n/a, dies on invalid data
# note:   most validation errors are self-explanatory
# note:   one validation error is cryptic:
#           '/repos/X: Should not match'
#         means the 'else' clause in '$defs/repo' has been violated, that is,
#         the 'obtain-method' property is *not* set to 'download-release-asset'
#         and yet it has either or both of the properties 'asset-type' or
#         'release-path-extraction-regex'
sub _validate_config_data ($self, $data) {
  my $schema    = $self->_config_schema;
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

App::My::PandocUpdateTemplates::Update - update local pandoc templates

=head1 VERSION

This documentation is for App::My::PandocUpdateTemplates::Update version 0.1.

=head1 SYNOPSIS

    use strictures 2;
    use 5.006;
    use 5.038_001;
    use namespace::clean;
    use App::My::PandocUpdateTemplates::Update;

    App::My::PandocUpdateTemplates::Update->new_with_options->run;

=head1 DESCRIPTION

This module updates local pandoc templates. It relies on the following
assumptions:

=over

=item *

The template files are installed via a F<stow> package.

=item *

All template files originate from online repositories.

=item *

All repositories can be downloaded by either a C<git clone> command or by
downloading and extracting a single asset release file (github sematics are
assumed)

=back

=head2 Update process

The update process consists of the following steps:

=over

=item 1.

Download the specified repositories to temporary directories

=item 2.

perform substitutions on file content

=item 3.

copy new and changed build files to the stow package, renaming where necessary.

=back

The temporary directories are automatically deleted.

Key directory and repository information information is specified in a
configuration file. See L</CONFIGURATION AND ENVIRONMENT> below for details.

The module performs checks on the downloaded files and attempts to identify
any changes that have occurred since the previous update. If changes are
detected, they are reported to the user who decides whether to proceed with
updating the stow package.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Options

=head3 repository (-r)

String. Name of a repository to update. Multiple allowed.
This enables the user to specify which repository or repositories to update.
Default if this option is not used: update all repositories.

=head3 show_config_data (-c)

Flag. Show configuration data and exit.

=head2 Properties/attributes

No public properties/attributes.

=head2 Configuration file

=head3 Location and format

The module looks for a configuration file with the base name
F<pandoc-my-update-templates> in the standard configuration locations.
Supported file formats include ini, json, xml, and yaml. The file extension
should match the file format, for example, F<.json> for json formatted files.
Warning: only the json format has been thoroughly tested with this module.

=head3 Structure

The easiest way to show the configuration file format is with an example, in
this case in json format:

  {
    "repos": [
      {
        "name": "buttondown",
        "description": "personal github fork of the ryangray/buttondown repo",
        "download-url": "https://github.com/dnebauer/buttondown.git",
        "obtain-method": "git-clone-repository",
        "filepath-mappings": [
          ["DOWNLOAD_ROOT/buttondown.css", "STOW_TEMPLATES_DIR/buttondown.css"]
        ],
        "ignore": [
          "DOWNLOAD_ROOT/LICENSE.md",
          "DOWNLOAD_ROOT/pandoc_example.bat",
          "DOWNLOAD_ROOT/pandoc_example.html",
          "DOWNLOAD_ROOT/pandoc_example.md",
          "DOWNLOAD_ROOT/pandoc_example.sh",
          "DOWNLOAD_ROOT/README.md"
        ],
        "substitutions": []
      },
      {
        "name": "eisvogel",
        "description": "extract eisvogel templates from current repo release",
        "download-url": "https://github.com/Wandmalfarbe/.../Eisvogel.tar.gz",
        "asset-type": "targz",
        "obtain-method": "download-release-asset",
        "release-path-extraction-regex": "^DOWNLOAD_ROOT\/(Eisvogel-[^.]+[.][^.]+[.][^/]+)[/].*$",
        "filepath-mappings": [
          [
            "DOWNLOAD_ROOT/RELEASE_PATH/eisvogel.beamer",
            "STOW_TEMPLATES_DIR/my-eisvogel.beamer"
          ],
          [
            "DOWNLOAD_ROOT/RELEASE_PATH/eisvogel.latex",
            "STOW_TEMPLATES_DIR/my-eisvogel.latex"
          ]
        ],
        "delete-after-download": [
          "DOWNLOAD_ROOT/RELEASE_PATH/examples",
          "DOWNLOAD_ROOT/RELEASE_PATH/template-multi-file"
        ],
        "ignore": [
          "DOWNLOAD_ROOT/RELEASE_PATH/CHANGELOG.md",
        ],
        "substitutions": []
      },
    ],
    "stow": {
      "template-dir": "HOME/.config/dotfiles/pandoc/.local/share/pandoc/templates",
      "extra": ["MyReadme.md"]
    }
  }

The components of the configuration file are explained here. JSON schema
terminology is used: arrays and strings are easily understood;
objects correspond to hashes, dicts and dictionaries in other languages and
schemas; properties correspond to hash/dict/dictionary keys; and a
string(enumeration) means a string that must be one of a set of allowed values.

=over

=over

=item / → stow

Object. Required. Required children: <template-dir>, <extra>.

=item / → stow → template-dir

String. Required. Absolute path to pandoc templates directory in stow package.
Often corresponds to F<~/.local/share/pandoc/templates/>.

=item / → stow → extras

Array of strings. Required (but can be empty). Absolute paths of files under
the stow package directory which are I<not> provided by any of the online
repositories, that is, they are maintained manually by the user.

=item / → repos

Array of <repo> objects. Required (can be empty, but what would be the point).

=item / → repos → repo

Object. Optional (but what would be the point of an empty <repos> array).
Models a single online repository.

=item / → repos → repo → name

String. Required. Human-understable name of repository. Used in feedback to
user and should be short. Can contain spaces but visual output is more legible
when it does not.

=item / → repos → repo → description

String. Required. Brief desciption of repository that is not used by the
module.

=item / → repos → repo → download-url

String (url). Required. Currently only 2 kinds of url are supported and they
correspond to the allowable S<< <obtain-method> >> values: a url that can be
used by the S<< <git clone> >> command (corresponding to the
S<< <obtain-method> >> value "git-clone-repository") or the url of one of a
repository's current/latest release asset files (corresponding to the
S<< <obtain-method> >> value "download-release-asset").

Release asset files are either versioned or unversioned according to the
preferences of the repository release manager. This module only supports
unversioned file names. As noted in the discussion of
S<< <release-path-extraction-regex> >>, however, the file tree extracted from
the release asset (archive) file may include a versioned subdirectory.

=item / → repos → repo → obtain-method

String (enumeration). Required. Allowed values: S<"git-clone-repository",>
S<"download-release-asset">. See the discussion of S<< <obtain-method> >> to
understand the effect of these values.

When set to S<"download-release-asset"> the <repo> properties
S<< <asset-type> >> and S<< <release-path-extraction-regex> >> are also
required. (These properties cannot be included when S<< <obtain-method> >> is
set to a different value.)

=item / → repos → repo → asset-type

String (enumeration). Required if and only if S<< <obtain-method> >> is set to
S<"download-release-asset">. Allowed value: "targz". This value is used to
determine the command used to extract the contents of the downloaded release
asset file.

=item / → repos → repo → release-path-extraction-regex

String. Required if and only if S<< <obtain-method> >> is set to
S<"download-release-asset">. A regular expression representing the absolute
path of files extracted from the downloaded release asset file. All capture
groups are joined to form a single string representing the part of the file
path that changes with each version change, that is, the part of the file path
reflecting the release version. The example above includes one capture group in
this regex that corresponds to S<< F<Eisvogel-X.Y.Z> >> where F<X>, F<Y> and
F<Z> are version numbers. For release v3.4.0 it would extract
S<< F<Eisovogel-3.4.0> >>.

Warning: if this regular expression does not match each extracted file value
the module will throw a fatal error.

If the paths of the files extracted from the downloaded release asset archive
do not contained a versioned portion, the RELEASE_PATH token will not be used
in any configuration file values. In that case, simply set this property to
C<.*> to ensure it matches any value and this does not cause a fatal error.

The extracted regex value corresponds to the "RELEASE_PATH" token used in
S<< <filepath-mappings> >> (see the discussion of that property for more
details).

=item / → repos → repo → filepath-mappings

Array of arrays. Required (can be empty but what would be the point). Each
contained array corresponds to a downloaded repository file that will be copied
to the stow package template directory.

Each contained array has two elements: the first is the absolute path of a
downloaded repository file and the second is the absolute path of the
corresponding file in the stow templates directory. The absolute path of the
downloaded repository file can contain the "DOWNLOAD_ROOT" and "RELEASE_PATH"
placeholder tokens. The stow template file paths can contain the
"STOW_TEMPLATES_DIR" placeholder token. Placeholder tokens are discussed below.

=item / → repos → repo → delete-after-download

Array of strings. Required (can be empty). Each string is the absolute filepath
of a downloaded repository file or directory that will be deleted immediately
after download and so will not be copied into the stow templates directory.
Each path can contain the "DOWNLOAD_ROOT" and "RELEASE_PATH" placeholder
tokens. Placeholder tokens are discussed below.

This property has the same final effect as the S<< <repo> → <ignore> >>
property. The S<< <delete-after-download> >> property is useful because a
single directory entry results in the recursive deletion of all the files and
directories it contains. Use it when it is not necessary to track the
individual files in a subdirectory.

=item / → repos → repo → ignore

Array of strings. Required (can be empty). Each string is the absolute filepath
of a downloaded repository file that will I<not> be copied to the stow package
template directory. Each path can contain the "DOWNLOAD_ROOT" and
"RELEASE_PATH" placeholder tokens. Placeholder tokens are discussed below.

This property has the same final effect as the
S<< <repo> → <delete-after-download> >> property, except that every file must
be individually specified. Use S<< <repo> → <ignore> >> when you are deleting
a subset of files from a subdirectory or when it is important to know when the
repository adds or removes individual files from the subdirectory.

=item / → repos → repo → substitutions

Array of arrays. Required (but can be empty). Each contained array represents
a text substitution made to the content of the downloaded repository files.
Each contained array contains two elements: the first is a plain string to be
searched for and the second is a plain string to replace each occurrence of the
first string.

This is a very unsophisticated mechanism: every downloaded repository file to
be copied to the stow package templates directory undergoes a complete search
and replace. The search and replace string can contain placeholder tokens which
are themselves replaced before they are used in the search and replace
operations.

=back

=back

=head3 Placeholder tokens

The following placeholders can be used in configuration file values. The tokens
can be used in any string configuration value.

=over

=over

=item DOWNLOAD_ROOT

The absolute path of a repository's download directory (with no trailing slash).

Commonly used in:

=over

=item *

/ → repos → repo → filepath-mappings → [first array value]

=item *

/ → repos → repo → delete-after-download

=item *

/ → repos → repo → ignore

=item *

/ → repos → repo → release-path-extraction-regex

=back

=item HOME

The absolute path of the user's home directory (with no trailing slash).

Commonly used in:

=over

=item *

/ → stow → template-dir

=back

=item RELEASE_PATH

Will be replaced with the part of the absolute path for all downloaded
repository files extracted by the regular expression defined in
<S<< release-path-extraction-regex> >>.

As noted in the discussion of <S<< release-path-extraction-regex> >>, this
token is not needed if files extracted from a downloaded release asset archive
do not contain a versioned portion. If it is used, it is cmmonly used in:

=over

=item *

/ → repos → repo → filepath-mappings → [first array value]

=item *

/ → repos → repo → delete-after-download

=item *

/ → repos → repo → ignore

=back

=item STOW_TEMPLATES_DIR

The absolute path to the stow package pandoc templates directory (with no trailing slash).

Defined in the configuration file's property: / → stow → template-dir.

Commonly used in:

=over

=item *

/ → repos → repo → filepath-mappings → [second array value]

=back

=back

=back

=head2 Environment variables

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

=head2 Can't extract release-path from repo 'NAME'

For repositories obtained by downloading and extracting a release asset archive
file, the module matches a regular expression against the filepaths of the
extracted files to obtain the versioned part of the path. This error occurs if
the regular expression provided by the configuration file does not match the
filepaths of the extracted files. It indicates that the regular expression is
incorrect.

=head2 Clone failed with error code: ERROR

Occurs when an attempt to clone an online repository fails.

=head2 Config file data error(s) detected: ...

Occurs when the configuration file fails validation. The module reports a
specicific error giving the part of the configuration file where validation
failed and an explanation of how validation failed.

While most messages are easily understood, one validation error is cryptic:
"/repos/X: Should not match". While there may be other possible causes for this
error, it most commonly means that the S<< <obtain-method> >> property is
I<not> set to "download-release-asset" and yet it has either or both of the
properties S<< <asset-type> >> or S<< <release-path-extraction-regex> >>.

=head2 Slurp failed

This error occurs during an attempt to perform a search and replace on build
files. If the operating system provided an error message it will be displayed
as well.

=head2 These repo files were not expected: FILES

=head2 These files are missing: FILES

=head2 These expected stow extra files are missing: FILES

=head2 These expected stow files are missing from the stow package: FILES

=head2 These stow package files were not expected: FILES

These warning messages are displayed when the module detects changes between
newly downloaded project files and those project files defined in the
configuration and present in the stow templates directory.

=head2 Unable to remove .git dir: ERROR

After cloning a repository any F<.git> directory is deleted. This error occurs
if that delete operation fails.

=head2 Unable to delete asset release file: ERROR

After downloading and extracting the contents of a repository release asset
file, the module attempts to delete the downloaded file. This error occurs if
that operation fails.

=head2 Write failed

This error occurs during an attempt to perform a search and replace on build
files. If the operating system provided an error message it will be displayed
as well.

=head1 INCOMPATIBILITIES

None known.

=head1 DEPENDENCIES

=head2 Perl modules

App::My::PandocUpdateTemplates::FilepathMapping,
App::My::PandocUpdateTemplates::Repository,
App::My::PandocUpdateTemplates::Substitution, Archive::Tar, Carp, Const::Fast,
English, Env, Feature::Compat::Try, File::Copy, File::Fetch, File::chdir,
Git::Repository, JSON::Validator::Schema::Draft201909, Moo, MooX::HandlesVia,
MooX::Options, namespace::clean, Path::Tiny, Role::Utils::Dn, strictures,
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
