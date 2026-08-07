#!/bin/bash
# Recording indicator for waybar (shows "  Recording" when active)
REC_FILE="/tmp/hyprland-screenrec-pid"

recording=false
if [ -f "$REC_FILE" ] && kill -0 "$(cat "$REC_FILE")" 2>/dev/null; then
    recording=true
elif [ -f "$REC_FILE" ]; then
    rm -f "$REC_FILE"
fi
if [ "$recording" = false ] && pgrep -x wf-recorder > /dev/null 2>&1; then
    recording=true
fi

if [ "$recording" = true ]; then
    echo '{"text": "  Recording", "class": "recording", "tooltip": ""}'
else
    echo '{"text": "", "class": "idle", "tooltip": ""}'
fi
