# editors

# terminal editor
term_editors=(nvim vim vi)
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

export NEOVIDE_MULTIGRID=1
