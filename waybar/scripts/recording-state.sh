#!/bin/bash
# Recording indicator for waybar (shows state text)
SOCKET="${XDG_RUNTIME_DIR}/hyprcapture/recording.sock"

recording=false
if [ -S "$SOCKET" ]; then
    state=$(socat -u UNIX-CONNECT:"$SOCKET" - 2>/dev/null)
    phase=$(echo "$state" | grep -o '"phase":"[^"]*"' | cut -d'"' -f4)
    if [ "$phase" = "recording" ] || [ "$phase" = "finalizing" ]; then
        recording=true
    fi
fi

if [ "$recording" = true ]; then
    echo '{"text": "  Recording", "class": "recording", "tooltip": ""}'
else
    echo '{"text": "", "class": "idle", "tooltip": ""}'
fi
