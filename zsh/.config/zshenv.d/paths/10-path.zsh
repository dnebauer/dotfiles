# PATH variable

# base system path
unset path PATH
export -T PATH path
typeset -U PATH path
path+=('/usr/local/bin')
path+=('/usr/bin')
path+=('/bin')
path+=('/usr/games')

# local executables
local_bin="$HOME/.local/bin"
[[ -d "$local_bin" ]] && path=("$local_bin" $path)
unset local_bin
