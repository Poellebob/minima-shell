#!/bin/bash

STATE_FILE="$HOME/.cache/edp1_monitor_res"

if [ -f "$STATE_FILE" ] && grep -q "1920x1080" "$STATE_FILE"; then
    hyprctl keyword monitor "eDP-1,preferred,0x0,1.6"
    echo "preferred" > "$STATE_FILE"
else
    hyprctl keyword monitor "eDP-1,1920x1080,0x0,1.6"
    echo "1920x1080" > "$STATE_FILE"
fi