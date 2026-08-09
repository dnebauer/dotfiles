# tiddlywiki

# plugins
if [[ ! -v tiddlywiki_plugin_path ]] ; then
    export -T TIDDLYWIKI_PLUGIN_PATH tiddlywiki_plugin_path
    typeset -U TIDDLYWIKI_PLUGIN_PATH tiddlywiki_plugin_path
fi

# user-installed
tw_plugins='/usr/local/share/tiddlywiki/plugins'
[[ -d "$tw_plugins" ]] && tiddlywiki_plugin_path+=("$tw_plugins")

# official: global install
tw_plugins='/usr/local/lib/node_modules/tiddlywiki/plugins'
[[ -d "$tw_plugins" ]] && tiddlywiki_plugin_path+=("$tw_plugins")

# official: local install
tw_plugins="$HOME/.local/lib/node_modules/tiddlywiki/plugins"
[[ -d "$tw_plugins" ]] && tiddlywiki_plugin_path+=("$tw_plugins")

unset tw_plugins
