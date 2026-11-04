#!/usr/bin/env bash
set -euo pipefail

flags=
if [[ ${1:-} == --allow-token ]]; then
    flags=r
fi

monitors=$(hyprctl -j monitors)
clients=$(hyprctl -j clients)

# XDPH's decimal window addresses are distinct from its shareable handles.
declare -A handles
windows=${XDPH_WINDOW_SHARING_LIST:-}
while [[ $windows == *'[HA>]'* ]]; do
    entry=${windows%%'[HA>]'*}
    windows=${windows#*'[HA>]'}
    handle=${entry%%'[HC>]'*}
    address=${entry##*'[HE>]'}
    if [[ $handle =~ ^[0-9]+$ && $address =~ ^[0-9]+$ && $address != 0 ]]; then
        handles[$address]=$handle
    fi
done

visible=$(jq -r --argjson monitors "$monitors" '
    .[]
    | select(.mapped and (.hidden | not))
    | select(.workspace.id as $id | any($monitors[];
        .activeWorkspace.id == $id or .specialWorkspace.id == $id))
    | [.address, .at[], .size[]] | @tsv
' <<< "$clients")

regions=
while read -r address x y width height; do
    [[ $address =~ ^0x[[:xdigit:]]+$ ]] || continue
    address=$((address))
    if [[ -n ${handles[$address]:-} ]]; then
        regions+="$x,$y ${width}x${height} window:${handles[$address]}"$'\n'
    fi
done <<< "$visible"

colors=()
branch=dark
if [[ -n ${MINIMA_CONFIG:-} ]] &&
    [[ $(jq -r '.theme.darkTheme' "$MINIMA_CONFIG" 2>/dev/null) == false ]]; then
    branch=light
fi
if palette=$(jq -er --arg branch "$branch" '
    .colors[$branch]
    | [.scrim, .primary]
    | select(all(.[]; type == "string" and test("^#[0-9a-fA-F]{6}$")))
    | @tsv
' "$HOME/.config/minima/colors.json" 2>/dev/null); then
    read -r scrim primary <<< "$palette"
    colors=(-b "${scrim}88" -c "${primary}ff" -s "${primary}22" -B "${primary}11")
fi

# Avoid blank stdin records, including when there are no shareable windows.
# Global geometry also lets slurp select windows whose top-left is off-screen.
selection=$(printf '%s' "$regions" | slurp "${colors[@]}" -o -d -f '%o|%x|%y|%w|%h|%l') || exit 1
IFS='|' read -r output x y width height label <<< "$selection"

case $label in
    window:*)
        source=$label
        ;;
    "")
        [[ $x =~ ^-?[0-9]+$ && $y =~ ^-?[0-9]+$ &&
            $width =~ ^[0-9]+$ && $height =~ ^[0-9]+$ ]] || exit 1
        (( width > 0 && height > 0 )) || exit 1
        # Portal regions are local to one output. Clip cross-output drags to it.
        geometry=$(jq -er --arg output "$output" \
            --argjson x "$x" --argjson y "$y" \
            --argjson width "$width" --argjson height "$height" '
            .[] | select(.name == $output)
            | (if (.transform % 2) == 1 then [.height, .width] else [.width, .height] end) as $size
            | ($x - .x) as $localX | ($y - .y) as $localY
            | [$localX, $localY,
                ([$width, (($size[0] / .scale | round) - $localX)] | min),
                ([$height, (($size[1] / .scale | round) - $localY)] | min)]
            | select(.[0] >= 0 and .[1] >= 0 and .[2] > 0 and .[3] > 0)
            | @tsv
        ' <<< "$monitors")
        read -r x y width height <<< "$geometry"
        source="region:$output@$x,$y,$width,$height"
        ;;
    *)
        jq -e --arg output "$label" 'any(.[]; .name == $output)' <<< "$monitors" >/dev/null
        source="screen:$label"
        ;;
esac

printf '[SELECTION]%s/%s\n' "$flags" "$source"
