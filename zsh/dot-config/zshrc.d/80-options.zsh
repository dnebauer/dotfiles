# Options

# type 'dir' instead of 'cd dir'
# - set by plugin
setopt auto_cd

# automatically push old directory into directory stack
# - set by plugin
setopt auto_pushd

# no multiples on directory stack
# - set by plugin
setopt pushd_ignore_dups

# swap '+' and '-' meanings for stack directory
# - set by plugin
setopt pushd_minus

# silence pushd messages
setopt pushd_silent

# can try to expand cd var by prepending '~'
# - set by plugin
setopt cdable_vars

# configure completion (override plugin-set options)
# move to end of word on completion
setopt always_to_end

# complete from both ends of word
setopt complete_in_word

# history saves command timestamp and duration
# - set by plugin
setopt extended_history

# expire duplicate commands first
# - set by plugin
setopt hist_expire_dups_first

# do not add duplicate command to history
# - set by plugin
setopt hist_ignore_dups

# remove history command if starts with space
# - set by plugin
setopt hist_ignore_space

# if enter history line, reload in edit buffer
# - set by plugin
setopt hist_verify

# add commands to history immediately
# - set by plugin
setopt inc_append_history

# import new commands from history
# - set by plugin
setopt share_history

# disable ctrl-s/ctrl-q flow control
# - set by plugin
setopt no_flow_control

# list jobs in long format
# - set by plugin
setopt long_list_jobs

# do expansions in prompt
# - set by plugin
setopt prompt_subst

# expand globs
setopt glob_complete

# sort numeric file names numerically
setopt numeric_glob_sort

# parameter interpolation
# - xx=(a b c); foo${xx}bar => fooabar foobbar foocbar
setopt rc_expand_param

# 10 second wait before global deletion
setopt rm_star_wait

# correct spelling
setopt correct

# allow comments in interactive shells
setopt interactive_comments
