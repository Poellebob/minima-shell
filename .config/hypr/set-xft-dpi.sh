#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 \"<monitor_definition>\""
    exit 1
fi

INPUT="$1"
MONITOR_NAME="${INPUT%%,*}"
SCALE_FACTOR=$(echo "$INPUT" | awk -F',' '{print $4}')

[ -z "$SCALE_FACTOR" ] && SCALE_FACTOR=1

if [ -z "$MONITOR_NAME" ]; then
    MONITOR_NAME=$(hyprctl monitors | awk 'NR==1{print $2}')
    [ -z "$MONITOR_NAME" ] && { echo "Error: No monitors detected." >&2; exit 1; }
fi

resolution=$(hyprctl monitors | awk -v monitor="$MONITOR_NAME" '$2 == monitor {getline; print $1}')

[ -z "$resolution" ] && { echo "Error: Monitor '$MONITOR_NAME' not found." >&2; exit 1; }

width=${resolution%x*}
dpi=$(echo "96 * ($width / 1920) * $SCALE_FACTOR" | bc)

echo $width
echo "Xft.dpi: $dpi" | xrdb -merge
echo "Set Xft.dpi to $dpi for monitor '$MONITOR_NAME' (scale: $SCALE_FACTOR)"
