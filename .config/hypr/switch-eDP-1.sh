#!/bin/bash

STATE_FILE="$HOME/.cache/edp1_monitor_state"

if [ -f "$STATE_FILE" ] && grep -q "disabled" "$STATE_FILE"; then
    hyprctl keyword monitor "eDP-1,preferred,0x0,1.6"
    echo "enabled" > "$STATE_FILE"
else
    hyprctl keyword monitor "eDP-1,disable"
    echo "disabled" > "$STATE_FILE"
fi

