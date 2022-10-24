# Fortune

if command -v fortune &>/dev/null ; then
    echo "${RED}Fortune for today:${RESET}"
    echo
    fortune
    echo
fi
