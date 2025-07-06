#!/bin/bash

# --- CONFIGURATION ---
# Find your battery name by running: ls /sys/class/power_supply/
BATTERY="CMB1"
LOW_LEVEL=25
CRITICAL_LEVEL=10
# ---------------------

# Get current battery capacity and status
CAPACITY=$(cat /sys/class/power_supply/$BATTERY/capacity)
STATUS=$(cat /sys/class/power_supply/$BATTERY/status)

# Check if the battery is discharging and below the configured levels
if [ "$STATUS" = "Discharging" ]; then
    if [ "$CAPACITY" -le "$CRITICAL_LEVEL" ]; then
        # Send a critical notification
        notify-send "Battery Critically Low" "Level: ${CAPACITY}%. Plug in immediately!" -u critical -i battery-caution-charging -t 10000
    elif [ "$CAPACITY" -le "$LOW_LEVEL" ]; then
        # Send a normal notification
        notify-send "Battery Low" "Level: ${CAPACITY}%. Consider plugging in." -u normal -i battery-caution -t 5000
    fi
fi
