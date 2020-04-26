export ZSH="/home/mark/.oh-my-zsh"

ZSH_THEME=""
plugins=(git)

source $ZSH/oh-my-zsh.sh

for f in $HOME/.zshrc.d/*.zsh; do
    source "$f"
done
