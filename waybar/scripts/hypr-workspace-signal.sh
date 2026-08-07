#!/usr/bin/env bash
# Listens on Hyprland's IPC event socket (socket2) and pings Waybar's
# custom workspace modules to redraw the instant the active workspace
# changes -- avoids polling on an interval, updates are instant.
#
# Requires: socat
# Run this once at session start (see hyprland.lua note below).

socket_path="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

socat -U - "UNIX-CONNECT:${socket_path}" | while read -r line; do
  case "$line" in
    workspace\>\>*|focusedmon\>\>*|createworkspace\>\>*|destroyworkspace\>\>*)
      # Matches the "signal": 8 set on each custom/wsN module below
      pkill -RTMIN+8 waybar
      ;;
  esac
done
