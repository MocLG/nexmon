#!/bin/bash
# monpass-wrapper.sh — enable monpass and launch wifite/aircrack tools
#
# Sourced usage:
#   source monpass-wrapper.sh          # enables monpass, exports LD_PRELOAD
#   wifite -i wlan0                    # run wifite directly
#
# Direct usage:
#   monpass-wrapper.sh start           # enable monpass
#   monpass-wrapper.sh stop            # disable monpass
#   monpass-wrapper.sh wifite          # enable monpass + run wifite -i wlan0

MONPASS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
NEXUTIL="${MONPASS_DIR}/nexutil/nexutil_glibc"
LIBNEXMON="${MONPASS_DIR}/libnexmon/libnexmon_glibc.so"
WLAN_IFACE="wlan0"

# Detect if sourced
sourced=0
[ -n "$BASH_VERSION" ] && [ "${BASH_SOURCE[0]}" != "$0" ] && sourced=1
[ -n "$ZSH_VERSION" ] && [[ "${ZSH_EVAL_CONTEXT:-}" == *:file* ]] && sourced=1

monpass_start() {
    echo "Enabling monpass on $WLAN_IFACE..."
    LD_PRELOAD="$LIBNEXMON" "$NEXUTIL" -M 2 2>/dev/null || {
        echo "ERROR: failed to enable monpass" >&2
        return 1
    }
    LD_PRELOAD="$LIBNEXMON" "$NEXUTIL" -m 2>/dev/null
    export LD_PRELOAD="$LIBNEXMON"
    echo "monpass active — LD_PRELOAD exported"
}

monpass_stop() {
    echo "Disabling monpass..."
    LD_PRELOAD="$LIBNEXMON" "$NEXUTIL" -M 0 2>/dev/null
    echo "done"
}

if [ "$sourced" -eq 1 ]; then
    monpass_start
    echo "Now run: wifite -i $WLAN_IFACE"
    return 0 2>/dev/null
fi

case "${1:-}" in
    start) monpass_start ;;
    stop)  monpass_stop ;;
    wifite)
        monpass_start
        exec command wifite -i "$WLAN_IFACE" "${@:2}"
        ;;
    "") echo "Usage: source $0   OR   $0 start|stop|wifite" ;;
    *)  echo "Unknown: $1" ; exit 1 ;;
esac
