if ! pactl list sink-inputs | grep -q 'Corked: no'; then
    systemctl suspend
fi