#!/bin/bash

set -euo pipefail

DRY_RUN=0
DOT_DIR=$HOME/.dotfiles
AGENT_UNIT=$HOME/.config/systemd/user/ssh-agent.service

if [ "$(pwd)" != "$DOT_DIR" ]; then
    echo "Run from $DOT_DIR"
    exit 1
fi

while getopts "n" opt; do
    case ${opt} in
        n)
            DRY_RUN=1
            ;;
        \?)
            echo "Usage: ${0##*/} [-n] [dir]"
            exit 0
        ;;
    esac
done
shift $((OPTIND - 1))

if [ "$#" -gt 0 ]; then
    DOT_DIR=$1
fi
echo "Installing into ${DOT_DIR}"

do_link_file() {
    SRC_FILE=$1
    DST_FILE=$2
    mkdir -p "$(dirname "$DST_FILE")"
    echo "- link $SRC_FILE -> $DST_FILE"
    if [ "$DRY_RUN" -eq "0" ]; then
        ln -sf "$SRC_FILE" "$DST_FILE"
    fi
}

link_file() {
    SRC_FILE=$DOT_DIR/$1
    DST_FILE=$HOME/$1
    if [ "$#" -gt 1 ]; then
        DST_FILE=$HOME/$2
    fi
    do_link_file "$SRC_FILE" "$DST_FILE"
}

link_files() {
    SRC_DIR=$1
    DST_DIR=$1
    if [ "$#" -gt 1 ]; then
        DST_DIR=$2
    fi
    find "$DOT_DIR/$SRC_DIR" -maxdepth 1 -type f | sort \
            | while read -r SRC_FILE; do
        DST_FILE="$HOME/$DST_DIR/$(basename "$SRC_FILE")"
        do_link_file "$SRC_FILE" "$DST_FILE"
    done
}

ssh_agent_unit() {
    if [ ! -e "$AGENT_UNIT" ]; then
        mkdir -p "$(dirname "$AGENT_UNIT")"
        cat << 'EOF' >> "$AGENT_UNIT"
[Unit]
Description=SSH key agent

[Service]
Type=forking
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
EOF
    fi
    systemctl --user enable ssh-agent
    systemctl --user start ssh-agent
}

link_files root .
link_file .ssh/config

if [ "$(ps -ocomm= 1)" == "systemd" ]; then
    echo "Adding ssh-agent systemd unit"
    if [ "$DRY_RUN" -eq "0" ]; then
        ssh_agent_unit
    fi
fi
