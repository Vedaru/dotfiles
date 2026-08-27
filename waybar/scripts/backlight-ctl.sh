#!/bin/bash
# waybar backlight controller — auto-detects the active backlight device.
# Works in any GPU mode (intel_backlight for iGPU/hybrid, nvidia_0 for dGPU-only).
#
# Usage: backlight-ctl.sh up|down|half|full|get

pick_device() {
    # Ordered preference: known iGPU/ACPI names first, then NVIDIA, then anything.
    for d in intel_backlight amdgpu_backlight acpi_video0 nvidia_0; do
        [ -d "/sys/class/backlight/$d" ] && { echo "$d"; return; }
    done
    ls /sys/class/backlight 2>/dev/null | head -1
}

DEV="$(pick_device)"
[ -z "$DEV" ] && { echo "no backlight device found" >&2; exit 1; }

case "${1:-get}" in
    up)   brightnessctl -d "$DEV" set +5% ;;
    down) pct=$(brightnessctl -d "$DEV" -m | cut -d, -f4 | tr -d '%')
          [ "$pct" -gt 5 ] && brightnessctl -d "$DEV" set 5%- ;;
    half) brightnessctl -d "$DEV" set 50% ;;
    full) brightnessctl -d "$DEV" set 100% ;;
    save) brightnessctl -d "$DEV" --save ;;
    restore) brightnessctl -d "$DEV" --restore ;;
    set)  brightnessctl -d "$DEV" set "${2:?usage: $0 set <value>}" ;;
    get)  brightnessctl -d "$DEV" -m | cut -d, -f4 | tr -d '%' ;;
    *)    echo "usage: $0 up|down|half|full|save|restore|set <value>|get" >&2; exit 2 ;;
esac
