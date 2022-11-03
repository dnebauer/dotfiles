# msmtpq

# - inherits from environmental variables
# - script warns to *not* enclose variable values in quotes when setting them

# program filepath
(){
    prog=$HOME/.local/bin/msmtpq
    [[ -d "$prog" ]] && export MSMTPQ=$prog
}

# queue directory
(){
    queue=$HOME/.local/mail/queue
    [[ -d "$queue" ]] && export MSMTPQ_Q=$queue
}

# log filepath
(){
    log=$HOME/.local/mail/log/msmtp.queue.log
    [[ -d "$log" ]] && export MSMTPQ_LOG=$log
}
