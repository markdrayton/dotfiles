# Mac OS git-prompt.sh
if [ -e /usr/local/etc/bash_completion.d/git-prompt.sh ]; then
    . /usr/local/etc/bash_completion.d/git-prompt.sh
fi

if type __git_ps1 > /dev/null; then
    # git branches in prompt
    PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'
    GIT_PS1_SHOWCOLORHINTS=1
fi
