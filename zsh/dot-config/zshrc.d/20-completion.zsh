# Completion

autoload -U +X compinit && compinit -u

# turn off old-style completion
zstyle ':completion:*' use-compctl false

# menu completion
# • based on http://zsh.sourceforge.net/Guide/zshguide06.html #6.2.3:
zstyle ':completion:*' menu select=10
bindkey -M menuselect '^o' accept-and-infer-next-history

# use bash completion scripts
# • /etc/bash_completion used to load the completion scripts in
#   /etc/bash_completion.d/, but now all it does is run
#   /usr/share/bash-completion/bash_completion, so there is no longer any need
#   to source /etc/bash_completion
# • running /usr/share/bash-completion/bash_completion in zsh seems to prevent
#   the completion scripts in /usr/share/bash-completion/completions/ from
#   sourcing, so don't run it
# • modern practice is to install completion scripts to
#   /usr/share/bash-completion/completions/ but there are still completion
#   scripts in their legacy install location of /etc/bash_completion.d/
bash_comp_d='/etc/bash_completion.d'
if [ -d "$bash_comp_d" ] ; then
    for file in "$bash_comp_d"/* ; do
        source $file 2>/dev/null
    done
fi
unset bash_comp_d
# • the following /usr/share/bash-completion/completions/ files break bash
#   completion in zsh:
breakers=(
    /usr/share/bash-completion/completions/compgen
    /usr/share/bash-completion/completions/complete
)
bash_comp='/usr/share/bash-completion/completions'
if [ -d "$bash_comp" ] ; then
    for file in "$bash_comp"/* ; do
# • ${(M)array[@]:#${pattern}} is zsh-fu that expands to elements of array
#   ${array} that match pattern ${pattern}
# • so the following line tests for ${file} values that do not occur in array
#   ${breakers}
        if [[ -z "${(M)breakers[@]:#${file}}" ]] ; then
            source $file 2>/dev/null
        fi
    done
fi
unset bash_comp

# fasd command line completion
eval "$(fasd --init auto)"

# default completion for commands without defined completion
compdef _gnu_generic \
    cd     convert display dpkg find gunzip \
    iconv  lintian man     mc   pass perl \
    python rsync   sup-add sudo tar  vcsh

# options suggested by zsh plugin fzf-tab
# taken from https://github.com/Aloxaf/fzf-tab#configure
# • disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# • set descriptions format to enable group support
# • NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# • set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# • force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# • preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# • custom fzf flags
# • NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# • to make fzf-tab follow FZF_DEFAULT_OPTS
# • NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# • switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# • use tmux's "popup" feature
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
