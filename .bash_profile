source ~/.bashrc

for f in $HOME/.bash_profile.d/*.sh; do
    source "$f"
done
