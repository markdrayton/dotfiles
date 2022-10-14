for f in /opt/homebrew/opt/fzf/shell/key-bindings.zsh /usr/share/fzf/key-bindings.zsh; do
    if [ -e "$f" ]; then
        source "$f"
        break
    fi
done
