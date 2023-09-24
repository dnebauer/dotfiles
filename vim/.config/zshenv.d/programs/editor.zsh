# editors

nvim_appimage=/usr/local/bin/nvim.appimage

# terminal editor
term_editors=($nvim_appimage nvim vim vi)
for term_editor in "${term_editors[@]}" ; do
    if type "$term_editor" > /dev/null 2>&1; then
        export EDITOR="$term_editor"
        alias vim="$term_editor"
        break
    fi
done
unset term_editor term_editors

export USE_EDITOR="$EDITOR"

# visual/gui editor
gui_editors=(neovide vim-qt "$EDITOR")
for gui_editor in "${gui_editors[@]}" ; do
    if type "$gui_editor" > /dev/null 2>&1; then
        export VISUAL="$gui_editor"
        alias gvim="$gui_editor"
        break
    fi
done
unset gui_editor gui_editors

# - if prefer nvim.appimage how to inform gui nvim?
# - some gui nvims (such as neovide) honour $NEOVIM_BIN
[[ "$EDITOR"x = "$nvim_appimage"x ]] && export NEOVIM_BIN=$nvim_appimage
unset nvim_appimage

# - some neovide-specific envvars
[[ "$VISUAL"x = 'neovide'x ]] && export NEOVIDE_MULTIGRID=1
