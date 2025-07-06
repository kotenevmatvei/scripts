#!/bin/bash
#
# A wofi-based menu for bluetoothctl.
#
# v2 with corrected list_devices function to prevent hanging processes.
#

# Function to show a notification
notify() {
    notify-send "Bluetooth" "$1"
}

# Get the status of the bluetooth controller
power_status() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        echo "󰂯 Power: On"
    else
        echo "󰂲 Power: Off"
    fi
}

# Toggle bluetooth power
toggle_power() {
    if [[ "$(power_status)" == *"On"* ]]; then
        bluetoothctl power off
        notify "Bluetooth turned off."
    else
        bluetoothctl power on
        notify "Bluetooth turned on."
    fi
}

# Get a list of devices with their connection status (CORRECTED VERSION)
list_devices() {
    # Get all known devices
    all_devices_list=$(bluetoothctl devices)
    # Get ONLY the MAC addresses of currently connected devices.
    connected_macs_list=$(bluetoothctl devices Connected | awk '{print $2}')

    # Loop through all devices and check if their MAC is in the connected list
    while read -r line; do
        # Skips empty lines
        if [ -z "$line" ]; then continue; fi

        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | sed "s/Device $mac //g")

        if echo "$connected_macs_list" | grep -qF "$mac"; then
            icon="󰂯" # Connected icon
        else
            icon="󰂲" # Disconnected icon
        fi
        
        echo "$icon $name ($mac)"
    done <<< "$all_devices_list"
}


# Main menu for actions
main_menu() {
    # Dynamic options
    power_option=$(power_status)
    scan_option="󰂰 Scan: On"
    if ! bluetoothctl show | grep -q "Discovering: yes"; then
        scan_option="󰂰 Scan: Off"
    fi

    # Wofi menu
    options="$power_option\n$scan_option\n󰂱 Connect\n󰂦 Disconnect\nTrusted Devices"
    
    selected_action=$(echo -e "$options" | wofi --dmenu --prompt "Bluetooth Menu")

    case "$selected_action" in
        *"Power"*)
            toggle_power
            ;;
        *"Scan"*)
            if [[ "$scan_option" == *"On"* ]]; then
                bluetoothctl scan off
                notify "Stopped scanning for devices."
            else
                # We run scan on in the background
                bluetoothctl scan on &
                notify "Scanning for new devices..."
            fi
            ;;
        *"Connect"*)
            connect_menu
            ;;
        *"Disconnect"*)
            disconnect_menu
            ;;
        *"Trusted"*)
            trust_menu
            ;;
    esac
}

# Menu to select a device to connect to
connect_menu() {
    selection=$(list_devices | wofi --dmenu --prompt "Connect to:")
    [ -z "$selection" ] && exit 0
    
    mac=$(echo "$selection" | grep -oE "([0-9A-F]{2}:){5}[0-9A-F]{2}")
    name=$(echo "$selection" | sed -E 's/.* (.*) \(.*\)/\1/') # Extract name

    if bluetoothctl connect "$mac"; then
        notify "Successfully connected to $name."
    else
        notify "Failed to connect to $name."
    fi
}

# Menu to select a device to disconnect from
disconnect_menu() {
    # We grep for the connected icon to ensure we only list devices that can be disconnected.
    selection=$(list_devices | grep "󰂯" | wofi --dmenu --prompt "Disconnect from:")
    [ -z "$selection" ] && exit 0

    mac=$(echo "$selection" | grep -oE "([0-9A-F]{2}:){5}[0-9A-F]{2}")
    name=$(echo "$selection" | sed -E 's/.* (.*) \(.*\)/\1/')

    if bluetoothctl disconnect "$mac"; then
        notify "Disconnected from $name."
    else
        notify "Failed to disconnect from $name."
    fi
}

# Menu to trust a device
trust_menu() {
    selection=$(list_devices | wofi --dmenu --prompt "Trust device:")
    [ -z "$selection" ] && exit 0

    mac=$(echo "$selection" | grep -oE "([0-9A-F]{2}:){5}[0-9A-F]{2}")
    name=$(echo "$selection" | sed -E 's/.* (.*) \(.*\)/\1/')

    if bluetoothctl trust "$mac"; then
        notify "Trusted $name."
    else
        notify "Failed to trust $name."
    fi
}

# Run the main menu
main_menu
