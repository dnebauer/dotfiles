# Aliases (must come last to override aliases set up by modules)

# ls
alias ls='ls -l --almost-all --color=auto'

# mp3info2 must use only tags, no deducing from file name
alias mp3info2='mp3info2 -C autoinfo=ID3v2,ID3v1'

# reload zshrc
alias reload=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"

# ag alias
# - set automatically by oh-my-zsh
# - remove alias if ag binary exists
if [ -f '/usr/bin/ag' ] ; then
    if [ $(alias 'ag' >/dev/null ; echo $?) -eq 0 ] ; then
        unalias 'ag'
    fi
fi

# mc alias
# - subshell support causes slow startup
alias mc='mc --nosubshell'

# ugrep aliases
if command -v ugrep >/dev/null ; then
    # - uq   = 'ug -Q'  = short & quick query UI
    #                     (interactive, uses .ugrep config)
    # - ux   = 'ug -UX' = short & quick binary pattern search
    #                     (uses .ugrep config)
    # - uz   = 'ug -z'  = short & quick compressed files and archives search
    #                     (uses .ugrep config)
    # - ugit = 'ug -R --ignore-files'
    #                   = works like git-grep and define your preferences
    #                     in .ugrep config
    typeset -A ug_aliases
    ug_aliases=(
        uq   'ug -Q'
        ux   'ug -UX'
        uz   'ug -z'
        ugit 'ug -R --ignore-files'
    )
    for cmd cmd_alias ("${(@kv)ug_aliases}") ; do
        [ $(alias "$cmd" >/dev/null ; echo $?) -eq 0 ] && unalias "$cmd"
        alias $cmd="$cmd_alias"
    done
    unset ug_aliases cmd cmd_alias
    # - grep   = 'ugrep -G'  = search with basic regular expressions (BRE)
    # - egrep  = 'ugrep -E'  = search with extended regular expressions (ERE)
    # - fgrep  = 'ugrep -F'  = find string(s)
    # - zgrep  = 'ugrep -zG' = search compressed files and archives with BRE
    # - zegrep = 'ugrep -zE' = search compressed files and archives with ERE
    # - zfgrep = 'ugrep -zF' = find string(s) in compressed files
    #                          and/or archives
    # - zpgrep = 'ugrep -zP' = search compressed files and archives
    #                          with Perl regular expressions
    # - zxgrep = 'ugrep -zW' = search (ERE) compressed files/archives
    #                          and output text or hex for binary
    typeset -A ugrep_aliases
    ugrep_aliases=(
        grep   'ugrep -G'
        egrep  'ugrep -E'
        fgrep  'ugrep -F'
        zgrep  'ugrep -zG'
        zegrep 'ugrep -zE'
        zfgrep 'ugrep -zF'
        zpgrep 'ugrep -zP'
        zxgrep 'ugrep -zW'
    )
    ugrep_hidden='--hidden --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
    typeset -a filters
    command -v pdftotext >/dev/null && filters+=('pdf:pdftotext % -')
    command -v soffice >/dev/null && \
        filters+=('odt,doc,docx,rtf,xls,xlsx,ppt,pptx:soffice --headless --cat %')
    ugrep_filter=''
    [[ ${#filters[@]} -gt 0 ]] && ugrep_filter="--filter='${(j:,:)filters}'"
    unset filters
    for cmd cmd_alias ("${(@kv)ugrep_aliases}") ; do
        [ $(alias "$cmd" >/dev/null ; echo $?) -eq 0 ] && unalias "$cmd"
        alias $cmd="$cmd_alias $ugrep_hidden $ugrep_filter"
    done
    unset ugrep_aliases ugrep_hidden ugrep_filter element cmd cmd_alias
fi
