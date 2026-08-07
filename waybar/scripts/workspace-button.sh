#!/usr/bin/env bash
# Outputs JSON for one workspace pill: text = the number, class = "active"
# if it's the currently focused workspace. Called once at Waybar startup,
# then re-run on demand whenever hypr-workspace-signal.sh below pings it.
#
# Requires: jq

ws="$1"

if [ -z "$ws" ]; then
  echo '{"text":"?","class":""}'
  exit 1
fi

active="$(hyprctl activeworkspace -j | jq -r '.id')"

if [ "$active" = "$ws" ]; then
  printf '{"text":"%s","class":"active"}\n' "$ws"
else
  printf '{"text":"%s","class":""}\n' "$ws"
fi
