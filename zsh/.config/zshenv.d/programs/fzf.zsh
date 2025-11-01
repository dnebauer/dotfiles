# configure the fzf-zsh-plugin
# • <https://github.com/unixorn/fzf-zsh-plugin>
export FZF_PREVIEW_ADVANCED=true
export FZF_PREVIEW_WINDOW='right:65%:nohidden'

# configure fzf
# • <https://medium.com/better-programming/boost-your-command-line-productivity-with-fuzzy-finder-985aa162ba5d>
export FZF_COMPLETION_TRIGGER='**'
export FZF_DEFAULT_OPTS="
--layout=reverse
--info=inline
--height=80%
--multi
--preview='([[ -f {} ]] && (batcat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2>/dev/null | head -n 200'
--preview-window=':nohidden'
--color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'
--prompt='∼ '
--pointer='▶'
--marker='✓'
--bind '?:toggle-preview'
--bind 'ctrl-a:select-all'
--bind 'ctrl-u:deselect-all'
--bind 'ctrl-y:execute-silent(echo {+} | pbcopy)'
--bind 'ctrl-e:execute(vim {+} >/dev/tty)'
--bind 'ctrl-v:execute(code {+})'
"
