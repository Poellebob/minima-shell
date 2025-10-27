#!/bin/bash

# Get username and hostname
if command -v hostname >/dev/null 2>&1; then
    host_name=$(hostname)
elif [ -f /etc/hostname ]; then
    host_name=$(cat /etc/hostname)
elif [ -f /proc/sys/kernel/hostname ]; then
    host_name=$(cat /proc/sys/kernel/hostname)
else
    host_name="unknown"
fi
user_host="${USER}@${host_name}"

# Get OS info
if [ -f /etc/os-release ]; then
    os=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)
elif [ -f /etc/arch-release ]; then
    os="Arch Linux"
elif [ -f /etc/debian_version ]; then
    os="Debian $(cat /etc/debian_version)"
else
    os=$(uname -s)
fi

# Get host info (try different methods)
if [ -f /sys/devices/virtual/dmi/id/product_name ]; then
    host=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null)
elif [ -f /sys/devices/virtual/dmi/id/board_name ]; then
    host=$(cat /sys/devices/virtual/dmi/id/board_name 2>/dev/null)
else
    host="Unknown"
fi

# Get kernel version
kernel=$(uname -r)

# Get uptime
uptime_raw=$(cat /proc/uptime | cut -d' ' -f1)
uptime_seconds=${uptime_raw%.*}
uptime_days=$((uptime_seconds / 86400))
uptime_hours=$(((uptime_seconds % 86400) / 3600))
uptime_minutes=$(((uptime_seconds % 3600) / 60))

if [ $uptime_days -gt 0 ]; then
    uptime="${uptime_days}d ${uptime_hours}h ${uptime_minutes}m"
elif [ $uptime_hours -gt 0 ]; then
    uptime="${uptime_hours}h ${uptime_minutes}m"
else
    uptime="${uptime_minutes}m"
fi

# Get package count (try different package managers)
pkgs=0
if command -v pacman >/dev/null 2>&1; then
    pkgs=$(pacman -Q 2>/dev/null | wc -l)
elif command -v dpkg >/dev/null 2>&1; then
    pkgs=$(dpkg -l 2>/dev/null | grep -c '^ii')
elif command -v rpm >/dev/null 2>&1; then
    pkgs=$(rpm -qa 2>/dev/null | wc -l)
elif command -v emerge >/dev/null 2>&1; then
    pkgs=$(find /var/db/pkg -mindepth 2 -maxdepth 2 -type d 2>/dev/null | wc -l)
fi

# Get memory info
memory_info=$(cat /proc/meminfo)
mem_total=$(echo "$memory_info" | grep '^MemTotal:' | awk '{print $2}')
mem_available=$(echo "$memory_info" | grep '^MemAvailable:' | awk '{print $2}')
mem_used=$((mem_total - mem_available))

# Convert to MB
mem_used_mb=$((mem_used / 1024))
mem_total_mb=$((mem_total / 1024))

# Theme colors (set THEME_MODE=light for light theme, default is dark)
# Set the path to your colors JSON file
COLORS_FILE="${COLORS_FILE:-$HOME/.config/quickshell/colors/colors.json}"

if [ -f "$COLORS_FILE" ]; then
    theme_mode="${THEME_MODE:-dark}"
    
    # Extract colors using grep and sed (no jq dependency)
    if [ "$theme_mode" = "light" ]; then
        label_color=$(grep -A 100 '"light"' "$COLORS_FILE" | grep '"outline"' | head -1 | sed 's/.*": *"\([^"]*\)".*/\1/')
        primary_color=$(grep -A 100 '"light"' "$COLORS_FILE" | grep '"primary"' | head -1 | sed 's/.*": *"\([^"]*\)".*/\1/')
        accent_color=$(grep -A 100 '"light"' "$COLORS_FILE" | grep '"green"' | head -1 | sed 's/.*": *"\([^"]*\)".*/\1/')
    else
        label_color=$(grep -A 100 '"dark"' "$COLORS_FILE" | grep '"outline"' | head -1 | sed 's/.*": *"\([^"]*\)".*/\1/')
        primary_color=$(grep -A 100 '"dark"' "$COLORS_FILE" | grep '"primary"' | head -1 | sed 's/.*": *"\([^"]*\)".*/\1/')
        accent_color=$(grep -A 100 '"dark"' "$COLORS_FILE" | grep '"green"' | head -1 | sed 's/.*": *"\([^"]*\)".*/\1/')
    fi
else
    # Fallback colors if file doesn't exist
    if [ "${THEME_MODE:-dark}" = "light" ]; then
        label_color="#72777f"
        primary_color="#2e628c"
        accent_color="#2d6a45"
    else
        label_color="#8c9198"
        primary_color="#9acbfa"
        accent_color="#95d5a7"
    fi
fi

# Print the fetch in Qt Quick Text compatible HTML
echo "<font color=\"$primary_color\"><b>$user_host</b></font><br>"
echo "<font color=\"$label_color\">os</font>     $os<br>"
echo "<font color=\"$label_color\">host</font>   $host<br>"
echo "<font color=\"$label_color\">kernel</font> $kernel<br>"
echo "<font color=\"$label_color\">uptime</font> $uptime<br>"
echo "<font color=\"$label_color\">pkgs</font>   $pkgs<br>"
echo "<font color=\"$label_color\">memory</font> <font color=\"$accent_color\">${mem_used_mb}M</font> / ${mem_total_mb}M"