# i3 window manager

# stop user services
(){
    services=(
        i3-my-focus-last
        i3-my-fullscreen-handler
        my-get-mail
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
