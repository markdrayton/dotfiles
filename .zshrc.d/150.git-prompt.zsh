ZSH_THEME_GIT_PROMPT_PREFIX=" (%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%})"
PROMPT='%n@%m:%~$(git_prompt_info)%(!.#.$) '
