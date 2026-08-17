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

# makoctl list prints one line per notification ("Notification <id>: <summary>")
notification_count=$(makoctl list 2>/dev/null | grep -c '^Notification' || true)

has_notifications=false
if [ "${notification_count:-0}" -gt 0 ] 2>/dev/null; then
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

if $dnd_active; then
    tooltip="Notifications: $notification_count (Do Not Disturb)"
else
    tooltip="Notifications: $notification_count"
fi

echo "{\"text\":\"\", \"alt\":\"$alt\", \"tooltip\":\"$tooltip\"}"
