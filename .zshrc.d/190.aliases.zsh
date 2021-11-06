alias youtube-dl='docker run \
    --rm -i \
    -e PGID=$(id -g) \
    -e PUID=$(id -u) \
    -v "$(pwd)":/workdir:rw \
    mikenye/youtube-dl'

alias readelf='readelf -M intel'
alias objdump='objdump -M intel'
