#!/usr/bin/env bash

if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    echo "needs bash version >= 4" >&2
    exit 1
fi

set -euo pipefail
shopt -s dotglob globstar nullglob

[[ "$0" == /* ]] && target=$(dirname "$0") || target=$PWD

touch dotfiles.skip

if [[ -f "$target/.manifest" ]]; then
    comm -23 <(sort "$target/.manifest") \
            <(git ls-tree -r HEAD --name-only | sort) | while read -r del; do
        rm -v "$HOME/$del"
    done
fi

for file in "$target"/**/*; do
    base="${file#$target/}"
    case "$base" in
        .git|.gitignore|.git/*|.manifest|dotfiles.skip|install.sh) continue ;;
    esac

    if [[ $(grep -sxF "$base" dotfiles.skip) ]]; then
        echo "Skipping $base" >&2
        continue
    fi

    if [[ -d "$base" ]]; then
        mkdir -pv "$HOME/$base"
    else
        ln -sfv "$file" "$HOME/$base"
    fi

    if [[ "$base" == ".ssh" ]]; then
        chmod 700 "$HOME/$base"
    fi
done

git ls-tree -r HEAD --name-only | grep -vsxFf dotfiles.skip > "$target/.manifest"
