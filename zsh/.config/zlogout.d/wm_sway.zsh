# sway window manager

if wmctrl -m >/dev/null 2>&1 ; then
    # still running a window manager

    # no actions to take

else
    # have presumably exited the window manager

    # unset variables
    unset QT_QPA_PLATFORMTHEME
    unset GRIM_DEFAULT_DIR
    unset _JAVA_AWT_WM_NONREPARENTING
    unset MOZ_ENABLE_WAYLAND
    unset QT_AUTO_SCREEN_SCALE_FACTOR
    unset QT_QPA_PLATFORM
    unset QT_QPA_PLATFORMTHEME
    unset QT_WAYLAND_DISABLE_WINDOWDECORATION
    unset GDK_BACKEND
    unset XDG_CURRENT_DESKTOP
    unset MY_PRIMARY_OUTPUT
    unset MY_SECONDARY_OUTPUT
fi
