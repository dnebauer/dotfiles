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
# - cargo-installed executables
local_cargo="$HOME/.cargo/bin"
[[ -d "$local_cargo" ]] && path=("$local_cargo" $path)
unset local_cargo
# - locally installed executables
local_bin="$HOME/.local/bin"
[[ -d "$local_bin" ]] && path=("$local_bin" $path)
unset local_bin
