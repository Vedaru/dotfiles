#!/usr/bin/env bash
# Returns JSON for waybar custom/notifications module
# Uses 'alt' field so format-icons can select the right icon

if ! pgrep -x mako >/dev/null 2>&1; then
    echo '{"text":"", "alt":"none", "tooltip":"mako not running"}'
    exit 0
fi

dnd_active=false
if makoctl mode 2>/dev/null | grep -q "do-not-disturb"; then
    dnd_active=true
fi

inhibited=false
if makoctl mode 2>/dev/null | grep -q "inhibited"; then
    inhibited=true
fi

has_notifications=false
notification_count=$(makoctl list 2>/dev/null | python3 -c "import sys,json; print(len(json.load(sys.stdin)['data']))" 2>/dev/null || echo 0)
if [ "$notification_count" -gt 0 ] 2>/dev/null; then
    has_notifications=true
fi

if $dnd_active && $inhibited && $has_notifications; then
    alt="dnd-inhibited-notification"
elif $dnd_active && $inhibited && ! $has_notifications; then
    alt="dnd-inhibited-none"
elif $dnd_active && $has_notifications; then
    alt="dnd-notification"
elif $dnd_active; then
    alt="dnd-none"
elif $inhibited && $has_notifications; then
    alt="inhibited-notification"
elif $inhibited; then
    alt="inhibited-none"
elif $has_notifications; then
    alt="notification"
else
    alt="none"
fi

echo "{\"text\":\"\", \"alt\":\"$alt\", \"tooltip\":\"Notifications: $notification_count\"}"
