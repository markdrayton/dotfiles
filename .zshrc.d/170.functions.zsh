,() {
    paste -sd, -
}

highlight() {
    local sede=()
    local i=1
    while [ "$1" ]; do
        local nexpr='s!\('$1'\)!'$'\e''['$((30+$i%8))'m\1'$'\e''[0m!g'
        sede=("${sede[@]}" "-e '$nexpr'")
        shift
        ((i++))
    done
    eval sed "${sede[@]}"
}

thread-last-run() {
    PID=$1
    if [ -z "$PID" ]; then
        echo "Usage: $FUNCNAME pid" >&2
        return
    fi
    # print time of last schedule relative to most recently scheduled thread
    for i in $(ps H -p $PID -o 'tid='); do
        echo $i $(sed 's/ /_/g' /proc/$i/comm) \
            $(awk '/se.exec_start/ { print $NF }' /proc/$i/sched)
    done | sort -rnk3 \
    | awk 'NR == 1 { VAL = $3 } { printf "%-7d %15s %3.2f\n", $1, $2, (VAL - $3) / 1000 }'
}

stats() {
    (
        echo "count avg min p1 p5 p25 p50 p75 p90 p95 p99 p99.9 max"

        sort -n | awk '
        BEGIN {
          i = 0
          t = 0
        }
        NR == 1 {
          min = $1
          max = $1
        }
        NR > 1 && $1 < min { min = $1 }
        NR > 1 && $1 > max { max = $1 }
        {
          t += $1
          s[i] = $1
          i++
        }
        END {
          print NR,
          t/NR,
          min,
          s[int(NR * 0.01 - 0.5)],
          s[int(NR * 0.05 - 0.5)],
          s[int(NR * 0.25 - 0.5)],
          s[int(NR * 0.50 - 0.5)],
          s[int(NR * 0.75 - 0.5)],
          s[int(NR * 0.90 - 0.5)],
          s[int(NR * 0.95 - 0.5)],
          s[int(NR * 0.99 - 0.5)],
          s[int(NR * 0.999 - 0.5)],
          max
        }' 2> /dev/null
    ) | column -t
}

pid-addr-map() {
    PID=$1
    ADDR=$2
    ADDR=${ADDR##0x}
    if [ -z "$PID" -o -z "$ADDR" ]; then
        echo "Usage: $FUNCNAME pid address" >&2
        return
    fi
    if [ ! -e "/proc/$PID/maps" ]; then
        echo "no such pid $PID" >&2
        return
    fi
    awk -v addr=$ADDR '
        BEGIN {
            if (addr !~ /^0x/) {
                addr = strtonum("0x" addr)
            }
        }
        {
            split($0, cols, / /)
            split(cols[1], range, /-/)
            from = strtonum("0x" range[1])
            to = strtonum("0x" range[2])
            offset = strtonum("0x" cols[3])
            if (addr >= from && addr < to) {
                print $0
                printf("from base: 0x%x\n", addr - from + offset)
            }
        }
    ' /proc/$PID/maps
}

thread-names() {
    PID=$1
    if [ -z "$PID" ]; then
        echo "Usage: $FUNCNAME pid" >&2
        return
    fi
    for TID in /proc/$PID/task/*; do
        echo ${TID##*/} $(cat $TID/comm 2> /dev/null; [ $? -ne 0 ] && echo N/A)
    done
}

tmp() {
    if [ -n "$1" ]; then
        PATTERN="/tmp/mbd-$1-tmp.XXXXXX"
    else
        PATTERN=/tmp/mbd-tmp.XXXXXX
    fi
    cd $(mktemp -d "$PATTERN")
}

sus() {
    sort | uniq -c | sort -n
}

simpleserve() {
    port=${1:-8000}
    python3 -m http.server $port
}

if [[ "$(uname)" == "Darwin" ]]; then
    ch() {
        local cols sep
        cols=$((COLUMNS / 3))
        sep='{::}'

        tmpdb=/tmp/chrome-history.sqlite
        cp -f ~/Library/Application\ Support/Google/Chrome/Default/History $tmpdb

        sqlite3 -separator $sep $tmpdb \
            "select substr(title, 1, $cols), url
             from urls order by last_visit_time desc" \
        | awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' \
        | fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
    }

    fh() {
        local cols sep
        cols=$((COLUMNS / 3))
        sep='{::}'

        tmpdb=/tmp/firefox-history.sqlite
        profiles=(~/Library/Application\ Support/Firefox/Profiles/*)
        if [[ $#profiles -gt 1 ]]; then
            echo "more than one profile directory found" >&2
            return 1
        fi

        cp -f "${profiles[1]}/places.sqlite" $tmpdb

        sqlite3 -separator $sep $tmpdb \
            "select substr(title, 1, $cols), url
             from moz_places order by last_visit_date desc" \
        | awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' \
        | fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
    }

    tac() {
        tail -r -- "$@"
    }

    strava() {
        sls \
        | fzf --multi --no-sort --tac --header-lines=1 \
        | awk '{ print "https://www.strava.com/activities/" $2 }' \
        | xargs open
    }

    chain-dist() {
        id=$(cat ~/.chain-id)
        sls \
            | awk -v id=$id '
                    $2 == id {
                        go = 1
                    }
                    {
                        if (go && $6 == "R3") {
                            if ($3 == "VirtualRide") {
                                vkm += $4
                            }
                            km += $4
                            n++
                        }
                    }
                    END {
                        printf("%d rides, %d km (%d km indoors)\n", n, km, vkm)
                    }'
    }
fi

body() {
    IFS= read -r header
    printf '%s\n' "$header"
    "$@"
}
