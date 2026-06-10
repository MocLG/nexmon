#!/bin/bash
# monpass-wrapper.sh — airmon-ng replacement for monpass-based monitor mode
#
# Usage:
#   source monpass-wrapper.sh          # activates wrappers in current shell
#   monpass-wrapper.sh start [iface]   # enable monpass directly
#   monpass-wrapper.sh stop  [iface]   # disable monpass directly
#
# With wifite:
#   source monpass-wrapper.sh && wifite

MONPASS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
NEXUTIL="${MONPASS_DIR}/nexutil/nexutil_glibc"
LIBNEXMON="${MONPASS_DIR}/libnexmon/libnexmon_glibc.so"
WLAN_IFACE="wlan0"

# Detect if sourced
sourced=0
[ -n "$BASH_VERSION" ] && [ "${BASH_SOURCE[0]}" != "$0" ] && sourced=1
[ -n "$ZSH_VERSION" ] && [[ "${ZSH_EVAL_CONTEXT:-}" == *:file* ]] && sourced=1

airmon_start() {
    local iface="${1:-$WLAN_IFACE}"
    echo "Enabling monpass on $iface..."

    if [ ! -x "$NEXUTIL" ]; then
        echo "ERROR: nexutil not found at $NEXUTIL" >&2
        return 1
    fi

    LD_PRELOAD="$LIBNEXMON" "$NEXUTIL" -M 2 || {
        echo "ERROR: failed to enable monpass" >&2
        return 1
    }

    local status
    status=$(LD_PRELOAD="$LIBNEXMON" "$NEXUTIL" -m 2>/dev/null)
    echo "$status"

    echo ""
    echo "PHY	Interface	Driver		Chipset"
    echo "phy0	$iface	bcmdhd		BCM4375B1"
}

airmon_stop() {
    local iface="${1:-$WLAN_IFACE}"
    echo "Disabling monpass on $iface..."
    LD_PRELOAD="$LIBNEXMON" "$NEXUTIL" -M 0 2>/dev/null
    echo "done"
}

airmon_check() {
    local iface="${1:-$WLAN_IFACE}"
    echo "Checking for processes that may cause conflicts..."
    ps aux 2>/dev/null | grep -E "[w]pa_supplicant|[n]etworkmanager|[d]hclient|[d]hcpcd" | awk '{print $2, $11}'
    echo "done"
}

# Wrapper functions that auto-export LD_PRELOAD
airodump-ng()    { LD_PRELOAD="$LIBNEXMON" command airodump-ng "$@"; }
aireplay-ng()    { LD_PRELOAD="$LIBNEXMON" command aireplay-ng "$@"; }
aircrack-ng()    { command aircrack-ng "$@"; }
airdecap-ng()    { command airdecap-ng "$@"; }
packetforge-ng() { LD_PRELOAD="$LIBNEXMON" command packetforge-ng "$@"; }
iwconfig()       { LD_PRELOAD="$LIBNEXMON" command iwconfig "$@"; }
iwlist()         { LD_PRELOAD="$LIBNEXMON" command iwlist "$@"; }
iwpriv()         { LD_PRELOAD="$LIBNEXMON" command iwpriv "$@"; }

airmon-ng() {
    local cmd="$1"
    shift 2>/dev/null
    case "$cmd" in
        start) airmon_start "$@" ;;
        stop)  airmon_stop  "$@" ;;
        check) airmon_check "$@" ;;
        *)     echo "Usage: airmon-ng {start|stop|check} [interface]" ;;
    esac
}

if [ "$sourced" -eq 1 ]; then
    export LD_PRELOAD="$LIBNEXMON"
    export NEXUTIL
    export LIBNEXMON
    echo "monpass-wrapper: wrappers active (airodump-ng, aireplay-ng, airmon-ng, etc.)"
    return 0 2>/dev/null
fi

# Direct execution
case "${1:-}" in
    start) airmon_start "${2:-$WLAN_IFACE}" ;;
    stop)  airmon_stop  "${2:-$WLAN_IFACE}" ;;
    check) airmon_check "${2:-$WLAN_IFACE}" ;;
    "") echo "Usage: source $0 && wifite"
        echo "       $0 start [iface]"
        echo "       $0 stop  [iface]" ;;
    *)  echo "Unknown command: $1" ; exit 1 ;;
esac
