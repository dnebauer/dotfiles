# fpath variable

# local completions
local_completions="$HOME/.local/share/zsh/completions"
[[ -d "$local_completions" ]] && fpath=("$local_completions" $fpath)
unset local_completions
