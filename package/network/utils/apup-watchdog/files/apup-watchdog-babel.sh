#!/bin/sh
#
# Some Rights Reserved. 2026 Federico Pietro Briata
#
# Licensed under the GNU General Public License (GPL) version 2 or later
# and the 3-Clause BSD License.

# babeld refuses to start without interfaces: it is started on the first peer and
# the others are added through its local configuration server on ::1 (BusyBox nc
# cannot reach a unix socket).
BABEL_PORT=6697
BABEL_PID=/var/run/apup-babeld.pid
PEERS=
NODE_IP=

babel_running() {
    [ -s "$BABEL_PID" ] && kill -0 "$(cat "$BABEL_PID")" 2>/dev/null
}

# $1: configuration statement for the running babeld; succeeds when it answers ok
babel_cmd() {
    printf '%s\nquit\n' "$1" | nc ::1 "$BABEL_PORT" 2>/dev/null |
        awk '$1 == "ok" {n++} $1 == "no" || $1 == "bad" {bad=1} END {exit !(n == 2 && !bad)}'
}

stop_babel() {
    babel_running && kill "$(cat "$BABEL_PID")"
    rm -f "$BABEL_PID"
}
trap 'stop_babel; exit 0' TERM INT

logger -t apup-watchdog "Watcher started: waiting for *.staX interfaces..."
while true; do
    # The node address is the /32 that netifd keeps on lo
    [ -n "$NODE_IP" ] || NODE_IP=$(ip -4 -o addr show dev lo | awk '$4 !~ /^127\./ {sub("/.*", "", $4); print $4; exit}')
    if [ -n "$NODE_IP" ]; then
        NET_PREFIX=${NODE_IP%.*.*}
        # babeld died: the peers have to be added again
        babel_running || PEERS=
        for sta_path in /sys/class/net/*.sta*; do
            [ -e "$sta_path" ] || continue
            sta_if=${sta_path##*/}
            case "${sta_if##*.sta}" in
                ''|*[!0-9]*) continue ;;
            esac
            case " $PEERS " in
                *" $sta_if "*) continue ;;
            esac
            ip link set dev "$sta_if" up
            if babel_running; then
                logger -t apup-watchdog "Adding $sta_if"
                babel_cmd "interface $sta_if" || continue
            else
                logger -t apup-watchdog "Starting babeld on $sta_if"
                # A random router-id: a node that reboots is not ignored while the others still hold its old state
                babeld -r -S /var/run/apup-babel-state -G "$BABEL_PORT" \
                    -C 'default type wireless' \
                    -C "install ip $NET_PREFIX.0.0/16 le 32 pref-src $NODE_IP" \
                    -C "redistribute local ip $NODE_IP/32 allow" \
                    -C 'redistribute local deny' \
                    "$sta_if" &
                echo $! > "$BABEL_PID"
            fi
            PEERS="$PEERS $sta_if"
        done
    fi
    sleep 2
done
