#!/bin/bash
# Stop wf-recorder when clicked from waybar
REC_FILE="/tmp/hyprland-screenrec-pid"

if [ -f "$REC_FILE" ] && kill -0 "$(cat "$REC_FILE")" 2>/dev/null; then
    pid=$(cat "$REC_FILE")
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    rm -f "$REC_FILE"
    notify-send -i video-x-generic "Recording saved" "$(ls -t ~/Pictures/Screenshots/Recording_*.mp4 2>/dev/null | head -1)"
fi
