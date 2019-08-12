#!/usr/bin/env bash

if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    echo "needs bash version >= 4" >&2
    exit 1
fi

set -euo pipefail
shopt -s dotglob globstar nullglob

[[ "$0" == /* ]] && target=$(dirname "$0") || target=$PWD

if [[ -f "$target/.manifest" ]]; then
    comm -3 <(sort "$target/.manifest") \
            <(git ls-tree -r HEAD --name-only | sort) | while read -r del; do
        rm -v "$HOME/$del"
    done
fi

for file in "$target"/**/*; do
    base="${file#$target/}"
    case "$base" in
	.git|.gitignore|.git/*|.manifest|install.sh) continue ;;
    esac

    if [[ -d "$base" ]]; then
	mkdir -pv "$HOME/$base"
    else
        ln -sfv "$file" "$HOME/$base"
    fi
done

git ls-tree -r HEAD --name-only > "$target/.manifest"
