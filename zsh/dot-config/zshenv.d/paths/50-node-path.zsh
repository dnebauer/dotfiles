# NODE_PATH variable

# npm-installed apps
# * in ~/.npmrc is configured with prefix of ~/.local
if [[ -v node_path ]] ; then
    export -T NODE_PATH node_path
    typeset -U NODE_PATH node_path
fi
npm_mod="$HOME/.local/lib/node_modules"
[[ -d "$npm_mod" ]] && node_path+=("$npm_mod")
unset npm_mod
