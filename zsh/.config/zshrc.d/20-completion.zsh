# Completion

autoload -U +X compinit && compinit -u

# turn off old-style completion
zstyle ':completion:*' use-compctl false

# menu completion
# * based on http://zsh.sourceforge.net/Guide/zshguide06.html #6.2.3:
zstyle ':completion:*' menu select=10
bindkey -M menuselect '^o' accept-and-infer-next-history

# use bash completion scripts
# * /etc/bash_completion used to load the completion scripts in
#   /etc/bash_completion.d/, but now all it does is run
#   /usr/share/bash-completion/bash_completion, so there is no longer any need
#   to source /etc/bash_completion
# * running /usr/share/bash-completion/bash_completion in zsh seems to prevent
#   the completion scripts in /usr/share/bash-completion/completions/ from
#   sourcing, so don't run it
# * modern practice is to install completion scripts to
#   /usr/share/bash-completion/completions/ but there are still completion
#   scripts in their legacy install location of /etc/bash_completion.d/
bash_comp_d='/etc/bash_completion.d'
if [ -d "$bash_comp_d" ] ; then
    for file in "$bash_comp_d"/* ; do
        source $file 2>/dev/null
    done
fi
unset bash_comp_d
# * the following /usr/share/bash-completion/completions/ files break bash
#   completion in zsh:
breakers=(
    /usr/share/bash-completion/completions/compgen  \
    /usr/share/bash-completion/completions/complete \
)
bash_comp='/usr/share/bash-completion/completions'
if [ -d "$bash_comp" ] ; then
    for file in "$bash_comp"/* ; do
# * ${(M)array[@]:#${pattern}} is zsh-fu that expands to elements of array
#   ${array} that match pattern ${pattern}
# * so the following line tests for ${file} values that do not occur in array
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
