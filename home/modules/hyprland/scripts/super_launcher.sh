#!/usr/bin/env bash
# Helper script to show launcher when Super is pressed alone

echo "$(date): Launching overview" >> /tmp/super_launcher.log

# Use Hyprland global dispatcher to trigger QuickShell, fall back to fuzzel
hyprctl dispatch global quickshell:overviewToggleRelease || pkill fuzzel || fuzzel &
