export EDITOR=vim
export GOPATH=~/go
export GOBIN=$GOPATH/bin
export PATH=$HOME/bin:/opt/homebrew/bin:/usr/local/go/bin:$HOME/.githubcli/bin:$GOBIN:$PATH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""
plugins=(docker docker-compose git)

source $ZSH/oh-my-zsh.sh

for f in $HOME/.zshrc.d/*.zsh; do
    source "$f"
done

if [[ -e "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

eval "$(starship init zsh)"
