#!/usr/bin/env bash

# SCALE can be passed via env var (set at Nix eval time) or as first argument
if [ -z "$SCALE" ]; then
  SCALE="$1"
fi

if [ -n "$SCALE" ]; then
  scale=$(printf "%.2f" "$SCALE")
  # Try swaymsg for width, fall back to 1920
  width=$(swaymsg -t get_outputs -r 2>/dev/null | jq -r '.[] | select(.active) | .current_mode.width' | head -n1)
  [ -z "$width" ] && width=1920
else
  MONITOR_NAME="${1:-}"
  outputs_json=$(swaymsg -t get_outputs -r)

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

  [ -z "$width" ] && {
    echo "Error: Monitor '$MONITOR_NAME' not found." >&2
    exit 1
  }

  scale=$(echo "$outputs_json" | jq -r \
    --arg mon "$MONITOR_NAME" \
    '.[] | select(.name==$mon and .active) | .scale')
  scale=$(printf "%.2f" "$scale")
fi

# Compute DPI and round to nearest integer
dpi=$(echo "96 * ($width / 1920) * $scale" | bc -l)
dpi=$(printf "%.0f" "$dpi")

echo "Width: $width"
echo "Scale: $scale"
echo "Xft.dpi: $dpi" | xrdb -merge
echo "Set Xft.dpi to $dpi (scale=$scale, width=$width)"
