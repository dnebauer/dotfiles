# enable fzf keybindings
fzf_binary='fzf'
fzf_bindings='/usr/share/doc/fzf/examples/key-bindings.zsh'
if command -v "$fzf_binary" >/dev/null && [ -f "$fzf_bindings" ] ; then
    source "$fzf_bindings"
fi
unset fzf_binary fzf_bindings

# Vi keymap support

# help
bindkey -M vicmd 'H'   run-help
bindkey -M vicmd '^[h' run-help
bindkey -M viins '^[h' run-help
# history searching
autoload -Uz narrow-to-region
function _history-incremental-preserve-pattern-search-backward {
    local state
    MARK=CURSOR  # magick, else multiple ^R don't work
    narrow-to-region -p "$LBUFFER${BUFFER:+>>}" \
        -P "${BUFFER:+<<}$RBUFFER" -S state
    zle end-of-history
    zle history-incremental-pattern-search-backward
    narrow-to-region -R state
}
zle -N _history-incremental-preserve-pattern-search-backward
bindkey -M vicmd   '/'  _history-incremental-preserve-pattern-search-backward
bindkey -M vicmd   '?'  history-incremental-pattern-search-forward
bindkey -M viins   '^R' _history-incremental-preserve-pattern-search-backward
bindkey -M isearch '^R' history-incremental-pattern-search-backward
bindkey -M viins   '^S' history-incremental-pattern-search-forward
# special keys
# * note: to get key sequence for a key, do either of these in terminal:
#         Ctrl-v [press key]
#         cat >/dev/null [press Enter then key]
#         [thanks to http://zshwiki.org/home/zle/bindkeys for tip]
# * home key
#   default: invokes run-help on first token in line
bindkey -M viins '^[[H' vi-beginning-of-line
# * end key
#   default: after pressing <home>, <end> stops working
bindkey -M viins '^[[F' end-of-line
# * delete key
#   default: change case of next three characters and enter normal mode
bindkey -M viins '^[[3~' vi-delete-char
# * <Ctrl-x><h> keys
#   default: display function help
bindkey -M viins '^Xh' _complete_help

# Remap keys

# Shift+Space = no-break space    {{{2
display_server='x11'
if [[ -n "$XDG_SESSION_TYPE" ]] ; then
    if [[ 'wayland' = "$XDG_SESSION_TYPE" ]] ; then
        display_server='wayland'
    fi
else
    if command -v loginctl &>/dev/null && [[ -n "$XDG_SESSION_ID" ]] ; then
        output="$(loginctl show-session "$XDG_SESSION_ID" -p Type --value)"
        if [[ 'wayland' = "$output" ]] ; then
            display_server='wayland'
        fi
    fi
fi
[[ 'x11' = "$display_server" ]] && setxkbmap -option nbsp:level2
