#!/bin/bash
# waybar custom/backlight script — outputs JSON with icon + percentage

# Resolve device: prefer iGPU/ACPI, fall back to NVIDIA, then anything present
for d in intel_backlight amdgpu_backlight acpi_video0 nvidia_0; do
    [ -d "/sys/class/backlight/$d" ] && { DEVICE="$d"; break; }
done
[ -z "$DEVICE" ] && DEVICE=$(ls /sys/class/backlight | head -1)
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
