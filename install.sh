#!/bin/bash

set -euo pipefail
shopt -s dotglob globstar nullglob

if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    echo "needs bash version >= 4" >&2
    exit 1
fi

[[ "$0" == /* ]] && target=$(dirname "$0") || target=$PWD

for file in "$target"/**/*; do
    base="${file#$target/}"
    case "$base" in
	.git|.git/*|install.sh) continue ;;
    esac

    if [[ -d "$base" ]]; then
	mkdir -pv "$HOME/$base"
    else
        ln -sfv "$file" "$HOME/$base"
    fi
done

if [[ "$(ps -ocomm= 1)" == "systemd" ]]; then
    echo "Adding ssh-agent systemd unit"
    AGENT_UNIT=$HOME/.config/systemd/user/ssh-agent.service
    if [[ ! -e "$AGENT_UNIT" ]]; then
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
fi
