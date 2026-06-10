#!/bin/bash
# monpass-wrapper.sh — airmon-ng replacement for monpass-based monitor mode
#
# Usage:
#   source monpass-wrapper.sh          # activates wrappers in current shell
#   monpass-wrapper.sh airmon-ng ...   # runs the wrapper command directly
#
# Or with wifite:
#   source monpass-wrapper.sh && wifite

MONPASS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUTIL="${MONPASS_DIR}/nexutil/nexutil_glibc"
LIBNEXMON="${MONPASS_DIR}/libnexmon/libnexmon_glibc.so"
WLAN_IFACE="wlan0"

airmon_start() {
    local iface="${1:-$WLAN_IFACE}"
    echo "Enabling monpass on $iface..."

    if [ ! -x "$NEXUTIL" ]; then
        echo "ERROR: nexutil not found at $NEXUTIL" >&2
        return 1
    fi

    # Enable monpass
    LD_PRELOAD="$LIBNEXMON" "$NEXUTIL" -M 2
    if [ $? -ne 0 ]; then
        echo "ERROR: failed to enable monpass" >&2
        return 1
    fi

    # Verify
    local status
    status=$(LD_PRELOAD="$LIBNEXMON" "$NEXUTIL" -m 2>/dev/null)
    echo "$status"

    # Print output that wifite/airmon-ng expects
    echo ""
    echo "PHY	Interface	Driver		Chipset"
    echo "phy0	$iface	bcmdhd		BCM4375B1"
    echo ""
    echo "(monpass mode — interface name is still $iface, not wlan0mon)"
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
    local procs
    procs=$(ps aux 2>/dev/null | grep -E "[w]pa_supplicant|[n]etworkmanager|[d]hclient|[d]hcpcd" | awk '{print $2, $11}')
    if [ -n "$procs" ]; then
        echo "$procs"
    else
        echo "No conflicting processes found."
    fi
}

# Wrapper functions that export LD_PRELOAD automatically
airodump-ng()    { LD_PRELOAD="$LIBNEXMON" command airodump-ng "$@"; }
aireplay-ng()    { LD_PRELOAD="$LIBNEXMON" command aireplay-ng "$@"; }
aircrack-ng()    { command aircrack-ng "$@"; }
airdecap-ng()    { command airdecap-ng "$@"; }
packetforge-ng() { LD_PRELOAD="$LIBNEXMON" command packetforge-ng "$@"; }
iwconfig()       { LD_PRELOAD="$LIBNEXMON" command iwconfig "$@"; }
iwlist()         { LD_PRELOAD="$LIBNEXMON" command iwlist "$@"; }
iwpriv()         { LD_PRELOAD="$LIBNEXMON" command iwpriv "$@"; }

# airmon-ng: handle subcommands
airmon-ng() {
    local cmd="$1"
    shift 2>/dev/null
    case "$cmd" in
        start) airmon_start "$@" ;;
        stop)  airmon_stop  "$@" ;;
        check) airmon_check "$@" ;;
        "")    echo "Usage: airmon-ng {start|stop|check} [interface]" ;;
        *)     echo "Unknown airmon-ng command: $cmd" ;;
    esac
}

# If sourced, export the wrappers into the current shell
if [ "$(basename -- "$0")" != "monpass-wrapper.sh" ]; then
    echo "monpass-wrapper: wrappers active (airodump-ng, aireplay-ng, airmon-ng, etc.)"
    export LD_PRELOAD="$LIBNEXMON"
    export NEXUTIL
    export LIBNEXMON
    return 0 2>/dev/null || true
fi

# Executed directly — dispatch command or show usage
case "${1:-}" in
    start|stop|check) airmon_$1 "${2:-$WLAN_IFACE}" ;;
    "") echo "Usage: source $0  OR  $0 <command> [args]"
        echo "Commands:"
        echo "  start [iface]   Enable monpass monitor mode on interface (default: wlan0)"
        echo "  stop  [iface]   Disable monpass monitor mode"
        echo "  check [iface]   Check for conflicting processes"
        echo ""
        echo "With wifite: source $0 && wifite" ;;
    *)  echo "Unknown command: $1" ; exit 1 ;;
esac
