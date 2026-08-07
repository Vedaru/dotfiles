#!/bin/bash
# waybar custom/backlight script — outputs JSON with icon + percentage

DEVICE="intel_backlight"
PCT=$(brightnessctl -d "$DEVICE" -m | cut -d, -f4 | tr -d '%')

# Select icon based on brightness level
if [ "$PCT" -ge 80 ]; then
    ICON="󰃠"
elif [ "$PCT" -ge 50 ]; then
    ICON="󰃟"
elif [ "$PCT" -ge 20 ]; then
    ICON="󰃝"
else
    ICON="󰃞"
fi

echo "{\"text\": \"$ICON\", \"tooltip\": \"Brightness: $PCT%\", \"percentage\": $PCT}"
