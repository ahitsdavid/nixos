#!/usr/bin/env bash

# Get the window under the cursor
window_info=$(hyprctl activewindow -j)
window_pid=$(echo "$window_info" | jq -r '.pid')

# If we found a PID, try to get its working directory
if [ "$window_pid" != "null" ] && [ -n "$window_pid" ]; then
    # Check if the process has a cwd we can access
    if [ -L "/proc/$window_pid/cwd" ]; then
        cwd=$(readlink "/proc/$window_pid/cwd" 2>/dev/null)
        if [ -n "$cwd" ] && [ -d "$cwd" ]; then
            # Launch terminal in that directory using launch_first_available
            cd "$cwd" && ~/.config/hypr/scripts/launch_first_available.sh 'kitty' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' &
            exit 0
        fi
    fi
    
    # If that didn't work, try to find a child process (like a shell)
    children=$(pgrep -P "$window_pid" 2>/dev/null)
    for child in $children; do
        if [ -L "/proc/$child/cwd" ]; then
            cwd=$(readlink "/proc/$child/cwd" 2>/dev/null)
            if [ -n "$cwd" ] && [ -d "$cwd" ]; then
                cd "$cwd" && ~/.config/hypr/scripts/launch_first_available.sh 'kitty' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' &
                exit 0
            fi
        fi
    done
fi

# Fallback: use launch_first_available in home directory
~/.config/hypr/scripts/launch_first_available.sh 'kitty' 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm' &