#!/bin/sh
#
# Some Rights Reserved. 2026 Federico Pietro Briata
#
# Licensed under the GNU General Public License (GPL) version 2 or later
# and the 3-Clause BSD License.

MESH_IF=bat0
# WDS interfaces share the AP MAC address, but batman-adv needs a unique one on every hard interface
PRIMARY_IF=primary0

logger -t batman-watchdog "Watcher started: waiting for *.staX interfaces..."
while true; do
    # Added first so it stays the primary: the originator address no longer depends on which peer shows up first
    if ! batctl meshif "$MESH_IF" if | awk -v iface="$PRIMARY_IF:" '$1 == iface {found=1} END {exit !found}'; then
        AP_IF=$(ls /sys/class/net | grep -m 1 -E '^phy[0-9]+-ap[0-9]+$')
        if [ -n "$AP_IF" ]; then
            PHY_MAC=$(cat "/sys/class/net/$AP_IF/address")
            if ! ip link show dev "$PRIMARY_IF" >/dev/null 2>&1; then
                ip link add name "$PRIMARY_IF" type dummy
            fi
            ip link set "$PRIMARY_IF" address "46:${PHY_MAC#*:}"
            ip link set "$PRIMARY_IF" up
            batctl meshif "$MESH_IF" if add "$PRIMARY_IF"
        fi
    fi
    for sta_path in /sys/class/net/*.sta*; do
        [ -e "$sta_path" ] || continue
        sta_if=${sta_path##*/}
        PEER_NUM=${sta_if##*.sta}
        case "$PEER_NUM" in
            ''|*[!0-9]*) continue ;;
        esac
        MV_IF="mv${PEER_NUM}"
        if batctl meshif "$MESH_IF" if | awk -v iface="$MV_IF:" '$1 == iface {found=1} END {exit !found}'; then
            continue
        fi
        # Peer MAC on this WDS link; empty until hostapd has moved the station here, so retry on the next pass
        PEER_MAC=$(iw dev "$sta_if" station dump 2>/dev/null | awk '/^Station/ {print $2; exit}')
        [ -n "$PEER_MAC" ] || continue
        PHY_MAC=$(cat "$sta_path/address")
        # 02 (locally administered) + our MAC bytes 4-6 + peer MAC bytes 5-6: unique per peer, stable across reboots
        MV_MAC="02:$(printf '%s\n' "$PHY_MAC" | cut -d: -f4-6):$(printf '%s\n' "$PEER_MAC" | cut -d: -f5-6)"
        if ! ip link show dev "$MV_IF" >/dev/null 2>&1; then
            logger -t batman-watchdog "Creating $MV_IF on $sta_if with MAC $MV_MAC"
            ip link add link "$sta_if" name "$MV_IF" address "$MV_MAC" type macvlan mode bridge || continue
        fi
        ip link set dev "$MV_IF" up || continue
        batctl meshif "$MESH_IF" if add "$MV_IF"
    done
    sleep 2
done
