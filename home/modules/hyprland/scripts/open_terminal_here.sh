#!/usr/bin/env bash

# Simple approach: get the focused window's PID and find the deepest shell process
window_info=$(hyprctl activewindow -j)
window_pid=$(echo "$window_info" | jq -r '.pid')

if [ "$window_pid" != "null" ] && [ -n "$window_pid" ]; then
    # Find all child processes (including nested ones)
    all_pids=$(pgrep -P "$window_pid")
    
    # Add the parent PID to the list
    all_pids="$window_pid $all_pids"
    
    # Try to find the most recent shell process with a valid cwd
    best_cwd=""
    for pid in $all_pids; do
        if [ -L "/proc/$pid/cwd" ]; then
            cmd=$(ps -p "$pid" -o comm= 2>/dev/null | tr -d ' ')
            if [[ "$cmd" == "zsh" ]] || [[ "$cmd" == "bash" ]]; then
                cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null)
                if [ -n "$cwd" ] && [ -d "$cwd" ] && [ "$cwd" != "$HOME" ]; then
                    best_cwd="$cwd"
                fi
            fi
        fi
    done
    
    # If we found a good directory, use it
    if [ -n "$best_cwd" ]; then
        kitty --directory="$best_cwd" zsh &
        exit 0
    fi
fi

# Fallback: just launch kitty normally
kitty zsh &