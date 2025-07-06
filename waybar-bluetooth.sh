#!/bin/bash

# ~/.config/waybar/scripts/waybar-bluetooth.sh

# Function to get the current status and output JSON
output_status() {
    # Check if bluetooth is powered on
    if ! bluetoothctl show | grep -q "Powered: yes"; then
        # If not powered on, print a simple icon and exit the function
        echo '{"text": "󰂲 off", "tooltip": "Bluetooth is powered off", "class": "off"}'
        return
    fi

    # Get the names of connected devices. `bluetoothctl info` for each paired device.
    # The `grep` filters for the "Name" line of devices that are "Connected: yes".
    # `head -n 1` picks the first one if multiple are connected.
    connected_device_name=$(bluetoothctl devices Connected | awk 'NR==1 { if ($1 == "Device") { for(i=3; i<=NF; i++) printf "%s ", $i; print "" } ; exit }')

    if [ -n "$connected_device_name" ]; then
        # If a device is connected, show its name and a "connected" icon
        # The name is truncated to 20 characters to prevent it from being too long
        echo "{\"text\": \"󰂯 ${connected_device_name}\", \"tooltip\": \"Connected to: $connected_device_name\", \"class\": \"connected\"}"
    else
        # If powered on but no device is connected, show a "disconnected" icon
        echo '{"text": "󰂯 on", "tooltip": "Bluetooth on, but no device connected", "class": "disconnected"}'
    fi
}

# Initial output
output_status

# Listen for Bluetooth events and update on change
# This is more efficient than polling with a fixed interval.
dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',path_namespace='/org/bluez'" | while read -r; do
    # When a signal is received, re-run the status function
    output_status
done
