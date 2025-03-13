# Functions

# load user functions
config=${XDG_CONFIG_HOME:-$HOME/.config}
my_fpath="$config/zfunctions.d"
fpath=($my_fpath $fpath)
function autoload_my_fns {
    local fn
    for fn in $(ls -x $my_fpath); do
        if [ -x "$my_fpath/$fn" ] ; then
            autoload "$fn"
        else
            echo "Error: could not find function '$my_fpath/$fn'"
        fi
    done
}
autoload_my_fns

# configure user functions
# • execute 'git status' if empty enter in git-managed dir
if type -f magic-enter &>/dev/null ; then
    zle -N magic-enter
    bindkey -M viins   '^M'  magic-enter
fi

# ansi colours    {{{2
# • provides variables: RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, BLACK, WHITE
# • provides 'BOLD_' variants of the same colours
# • provides RESET
autoload colors && colors
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    eval export $COLOR='$fg_no_bold[${(L)COLOR}]'
    eval export BOLD_$COLOR='$fg_bold[${(L)COLOR}]'
done
eval export RESET='$reset_color'
