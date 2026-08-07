#!/bin/bash
# TLP battery info for waybar click

BAT_PATH="/sys/class/power_supply/BAT0"
NOW=$(cat "$BAT_PATH/energy_now" 2>/dev/null)
FULL=$(cat "$BAT_PATH/energy_full" 2>/dev/null)
FULL_DESIGN=$(cat "$BAT_PATH/energy_full_design" 2>/dev/null)
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null)
CYCLES=$(cat "$BAT_PATH/cycle_count" 2>/dev/null)
PCT=$(( NOW * 100 / FULL ))
HEALTH=$(( FULL * 100 / FULL_DESIGN ))

CONSERVATION=$(cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode 2>/dev/null)
[ "$CONSERVATION" = "1" ] && CONS_STATE="ON" || CONS_STATE="OFF"

TLP_MODE=$(tlp-stat -s 2>/dev/null | grep "Mode" | awk '{print $3}')
POWER_SRC=$(tlp-stat -s 2>/dev/null | grep "Power source" | awk '{print $3}')

notify-send -i battery \
    "Battery: $PCT% ($STATUS)" \
    "Power: $POWER_SRC  |  TLP: $TLP_MODE
Health: $HEALTH%  |  Cycles: $CYCLES
Conservation mode: $CONS_STATE
Toggle with: sudo tlp setcharge"
