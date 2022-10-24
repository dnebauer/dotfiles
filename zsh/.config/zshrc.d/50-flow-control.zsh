# Disable flow control (Ctrl-s, Ctrl-q)
# tip from http://www.reddit.com/r/commandline/comments/1dhame/tmux_and_konsole_have_something_called_flow/
stty stop  undef
stty start undef
stty -ixon
stty -ixoff
