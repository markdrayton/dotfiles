alias youtube-dl='docker run \
    --rm -i \
    -e PGID=$(id -g) \
    -e PUID=$(id -u) \
    -v "$(pwd)":/workdir:rw \
    mikenye/youtube-dl'

alias simpleserve='python3 -m http.server 8000'
