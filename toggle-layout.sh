#!/bin/sh

# --- SCRIPT CONFIGURATION ---
# The full path to the hyprctl command, found with "which hyprctl"
HYPRCTL_CMD="/usr/bin/hyprctl"

# Find your keyboard name by running: hyprctl devices
KEYBOARD_NAME="at-translated-set-2-keyboard"

# --- SCRIPT LOGIC ---
# Do not edit below this line

# Get the name of the currently active keymap
ACTIVE_LAYOUT=$(hyprctl devices -j | gojq -r ".keyboards[] | select(.name == \"$KEYBOARD_NAME\") | .active_keymap")

if [ "$ACTIVE_LAYOUT" = "German" ]; then
    # If it's German, switch to the 2nd layout (index 1)
    hyprctl switchxkblayout "$KEYBOARD_NAME" 1
else
    # Otherwise, switch back to the 1st layout (index 0)
    hyprctl switchxkblayout "$KEYBOARD_NAME" 0
fi
