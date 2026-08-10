#!/bin/bash
# Recording stop button — red dot, click to stop
# Queries HyprCapture's recording state socket
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
    echo '{"text": "●", "class": "recording", "tooltip": "Click to stop recording"}'
else
    echo '{"text": "", "class": "idle", "tooltip": ""}'
fi
