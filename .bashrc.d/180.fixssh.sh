fixssh() {
    if [[ -z "$TMUX" ]]; then
        echo "not in tmux" >&2
    else
        sock=$(tmux show-environment SSH_AUTH_SOCK 2> /dev/null)
        if [[ $? -eq 1 || -z "$sock" ]]; then
            echo "no SSH_AUTH_SOCK in tmux env" >&2
        else
            SSH_AUTH_SOCK=${sock##*=}
        fi
    fi
}
