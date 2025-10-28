#!/bin/sh

WALLPAPER_PATH=$(cat ~/.config/wallpaper.conf)

mkdir -p ~/.config/quickshell/old/colors/
touch ~/.config/quickshell/old/colors/colors.json

matugen -j hex image "$WALLPAPER_PATH" 2>/dev/null | grep '{' | jq . > ~/.config/quickshell/old/colors/colors.json

if [ ! -s ~/.config/quickshell/old/colors/colors.json ]; then
    echo "Error: matugen failed to generate colors.json. Make sure matugen is installed and the path in wallpaper.conf is correct."
    exit 1
fi

touch ~/.config/quickshell/old/colors/ColorsDark.qml
touch ~/.config/quickshell/old/colors/ColorsLight.qml

(echo "import QtQuick"
echo
echo "Colors {"

jq -r '.colors.dark  | to_entries | map("  "  + .key + ": \"" + .value + "\"") | .[]' ~/.config/quickshell/old/colors/colors.json

echo "}") > ~/.config/quickshell/old/colors/ColorsDark.qml

(echo "import QtQuick"
echo
echo "Colors {"

jq -r '.colors.light | to_entries | map("  " + .key + ": \"" + .value + "\"") | .[]' ~/.config/quickshell/old/colors/colors.json

echo "}") > ~/.config/quickshell/old/colors/ColorsLight.qml
