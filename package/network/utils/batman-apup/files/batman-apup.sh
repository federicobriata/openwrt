#!/bin/sh
#
# Some Rights Reserved. 2026 Federico Pietro Briata
#
# Licensed under the GNU General Public License (GPL) version 2 or later
# and the 3-Clause BSD License.

MESH_IF=bat0

logger -t batman-watchdog "Watcher started: waiting for *.staX interfaces..."
while true; do
    for sta_path in /sys/class/net/*.sta*; do
        [ -e "$sta_path" ] || continue
        sta_if=${sta_path##*/}
        if batctl meshif "$MESH_IF" if | awk -v iface="$sta_if:" '$1 == iface {found=1} END {exit !found}'; then
            continue
        fi
        logger -t batman-watchdog "Adding $sta_if to $MESH_IF"
        batctl meshif "$MESH_IF" if add "$sta_if"
    done
    sleep 2
done
