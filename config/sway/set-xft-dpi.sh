#!/usr/bin/env bash

MONITOR_NAME="$1"

outputs_json=$(swaymsg -t get_outputs -r)

# Use first active monitor if none provided
if [ -z "$MONITOR_NAME" ]; then
  MONITOR_NAME=$(echo "$outputs_json" | jq -r '.[] | select(.active) | .name' | head -n1)
  [ -z "$MONITOR_NAME" ] && {
    echo "Error: No monitors detected." >&2
    exit 1
  }
fi

width=$(echo "$outputs_json" | jq -r \
  --arg mon "$MONITOR_NAME" \
  '.[] | select(.name==$mon and .active) | .current_mode.width')

scale_raw=$(echo "$outputs_json" | jq -r \
  --arg mon "$MONITOR_NAME" \
  '.[] | select(.name==$mon and .active) | .scale')

[ -z "$width" ] && {
  echo "Error: Monitor '$MONITOR_NAME' not found." >&2
  exit 1
}

# Round scale to 2 decimals
scale=$(printf "%.2f" "$scale_raw")

# Compute DPI and round to nearest integer
dpi=$(echo "96 * ($width / 1920) * $scale" | bc -l)
dpi=$(printf "%.0f" "$dpi")

echo "Width: $width"
echo "Scale: $scale"
echo "Xft.dpi: $dpi" | xrdb -merge
echo "Set Xft.dpi to $dpi for monitor '$MONITOR_NAME'"
