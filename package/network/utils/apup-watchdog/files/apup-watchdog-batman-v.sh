#!/bin/sh
#
# Some Rights Reserved. 2026 Federico Pietro Briata
#
# Licensed under the GNU General Public License (GPL) version 2 or later
# and the 3-Clause BSD License.

MESH_IF=bat0

logger -t apup-watchdog "Watcher started: waiting for *.staX interfaces..."
# netifd creates bat0 with the routing_algo of /etc/config/network, which cannot change while bat0 exists
ALGO=$(batctl ra 2>/dev/null | awk -v iface="$MESH_IF:" '$1 == "*" && $2 == iface {print $3}')
[ "$ALGO" = BATMAN_V ] || logger -t apup-watchdog "WARNING: $MESH_IF runs ${ALGO:-no routing algorithm}, not BATMAN_V: set routing_algo in /etc/config/network"
while true; do
    for sta_path in /sys/class/net/*.sta*; do
        [ -e "$sta_path" ] || continue
        sta_if=${sta_path##*/}
        case "${sta_if##*.sta}" in
            ''|*[!0-9]*) continue ;;
        esac
        if batctl meshif "$MESH_IF" if | awk -v iface="$sta_if:" '$1 == iface {found=1} END {exit !found}'; then
            continue
        fi
        logger -t apup-watchdog "Adding $sta_if"
        batctl meshif "$MESH_IF" if add "$sta_if"
    done
    sleep 2
done
