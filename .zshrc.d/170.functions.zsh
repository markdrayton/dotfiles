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
    history-sql() {
        db=$1
        sql=$2
        local cols sep
        cols=$((COLUMNS / 3))
        sep='{::}'

        sqlite3 -separator $sep $db $sql \
            | awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", substr($1, 1, '$cols'), $2}' \
            | fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
    }

    chrome-history() {
        tmpdb=/tmp/chrome-history.sqlite
        cp -f ~/Library/Application\ Support/Google/Chrome/Default/History $tmpdb

        history-sql $tmpdb \
            "SELECT title, url FROM urls ORDER BY last_visit_time DESC"
    }

    firefox-history() {
        tmpdb=/tmp/firefox-history.sqlite
        profiles=(~/Library/Application\ Support/Firefox/Profiles/*)
        if [[ $#profiles -gt 1 ]]; then
            echo "more than one profile directory found" >&2
            return 1
        fi

        cp -f "${profiles[1]}/places.sqlite" $tmpdb

        history-sql $tmpdb \
            "SELECT title, url FROM moz_places ORDER BY last_visit_date DESC"
    }

    safari-history() {
        history-sql ~/Library/Safari/History.db \
            "SELECT DISTINCT hv.title, hi.url FROM history_items AS hi, history_visits AS hv
            WHERE hi.id = hv.history_item ORDER BY hv.visit_time DESC"
    }

    tac() {
        tail -r -- "$@"
    }

    strava() {
        sls "$@" \
        | fzf --multi --no-sort --tac --header-lines=1 \
        | awk '{ print "https://www.strava.com/activities/" $2 }' \
        | xargs open
    }

    chain-dist() {
        id=$(cat ~/.chain-id)
        sls -j \
            | jq -r '.[] | "\(.activity.id)\t\(.activity.type)\t\(.activity.external_id)\t\(.gear.name)\t\(.activity.distance)"' \
            | awk -v id=$id '
                    $1 == id {
                        go = 1
                    }
                    {
                        if (go && $4 == "R3") {
                            if ($2 == "VirtualRide" || $3 ~ /^(trainerroad|zwift)/) {
                                vkm += $5
                            }
                            km += $5
                            n++
                        }
                    }
                    END {
                        printf("%d rides, %d km (%d km indoors)\n", n, km / 1000, vkm / 1000)
                    }'
    }

    p2m-battery-dist() {
        id=$(cat ~/.p2m-battery-id)
        sls -j \
            | jq -r '.[] | "\(.activity.id)\t\(.activity.type)\t\(.activity.external_id)\t\(.gear.name)\t\(.activity.distance)\t\(.activity.moving_time)"' \
            | awk -v id=$id '
                    $1 == id {
                        go = 1
                    }
                    {
                        if (go && $4 == "R3") {
                            km += $5
                            secs += $6
                            n++
                        }
                    }
                    END {
                        printf("%d rides, %d km (approx %.1f hours)\n", n, km / 1000, secs / 3600)
                    }'
    }

    strava-curl() {
        token=$(jq -r .access_token < ~/.sls/token)
        curl -H "Authorization: Bearer $token" "$@"
    }
fi

body() {
    IFS= read -r header
    printf '%s\n' "$header"
    "$@"
}
