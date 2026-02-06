#!/bin/sh

WALLPAPER_PATH=$(cat ~/.config/wallpaper.conf)

mkdir -p ~/.config/quickshell/colors/
touch ~/.config/quickshell/colors/colors.json

matugen -j hex image "$WALLPAPER_PATH" 2>/dev/null | grep '{' | jq . > ~/.config/quickshell/colors/colors.json

if [ ! -s ~/.config/quickshell/colors/colors.json ]; then
    echo "Error: matugen failed to generate Global.colors.json. Make sure matugen is installed and the path in wallpaper.conf is correct."
    exit 1
fi

touch ~/.config/quickshell/colors/ColorsDark.qml
touch ~/.config/quickshell/colors/ColorsLight.qml

(echo "import QtQuick"
echo
echo "Colors {"

jq -r '.colors.dark  | to_entries | map("  "  + .key + ": \"" + .value + "\"") | .[]' ~/.config/quickshell/colors/colors.json

echo "}") > ~/.config/quickshell/colors/ColorsDark.qml

(echo "import QtQuick"
echo
echo "Colors {"

jq -r '.colors.light | to_entries | map("  " + .key + ": \"" + .value + "\"") | .[]' ~/.config/quickshell/colors/colors.json

echo "}") > ~/.config/quickshell/colors/ColorsLight.qml
