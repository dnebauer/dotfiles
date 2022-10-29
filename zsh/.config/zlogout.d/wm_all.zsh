# tiddlywiki plugin path

if wmctrl -m >/dev/null 2>&1 ; then
    # still running a window manager

    # no actions to take

else
    # have presumably exited the window manager

    # no longer running tiddlywiki
    unset TIDDLYWIKI_PLUGIN_PATH
fi
