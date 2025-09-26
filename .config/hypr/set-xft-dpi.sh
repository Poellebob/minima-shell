#!/bin/bash

# Script to set Xft.dpi based on a monitor's width ratio to 1920 (1080p width)
# Usage: ./set_xft_dpi.sh <monitor_name>

# Check if monitor name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <monitor_name>"
    exit 1
fi

MONITOR_NAME="$1"

# Extract resolution for the given monitor
resolution=$(hyprctl monitors | awk -v monitor="$MONITOR_NAME" '$2 == monitor {getline; print $1}')

# Check if resolution was found
if [ -z "$resolution" ]; then
    echo "Error: Monitor '$MONITOR_NAME' not found." >&2
    exit 1
fi

# Extract width
width=${resolution%x*}

# Base width for 1080p
base_width=1920

# Calculate DPI (96 * width_ratio)
dpi=$(echo "scale=2; 96 * ($width / $base_width)" | bc)

# Apply the new DPI setting to xrdb
echo "Xft.dpi: $dpi" | xrdb -merge
