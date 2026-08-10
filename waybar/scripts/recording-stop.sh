#!/bin/bash
# Stop HyprCapture recording when clicked from waybar
hyprctl eval "hl.plugin.hyprcapture.record_stop()" 2>/dev/null
