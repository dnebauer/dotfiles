# i3 window manager

if wmctrl -m >/dev/null 2>&1 ; then
    # still running a window manager

    # no actions to take

else
    # have presumably exited the window manager

    # stop user services
    (){
        services=(
            i3-my-focus-last
            i3-my-fullscreen-handler
            my-get-mail
            neomutt_aliases-regenerate
        )
        for service in "${services[@]}" ; do
            if systemctl --user --quiet is-active $service.service ; then
                systemctl --user stop $service.service
            fi
        done
    }

    # unset session variables
    unset MY_PRIMARY_OUTPUT
    unset MY_SECONDARY_OUTPUT
fi
