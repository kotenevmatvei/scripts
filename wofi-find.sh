#!/bin/bash

# Get the selected file or directory path from wofi
selected=$(fd . ~ --type f --type d | wofi --dmenu --prompt "Search Files")

# If a selection was made, open it with xdg-open
if [[ -n "$selected" ]]; then
    xdg-open "$selected"
fi
