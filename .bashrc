# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

for f in $HOME/.bashrc.d/*.sh; do
    source "$f"
done
