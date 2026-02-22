# minima-shell

minima-shell is a userspace shell and a [scroll](https://github.com/dawsers/scroll/)/[sway](https://swaywm.org/) and [hyprland](https://hypr.land/) config in one.

**Warning:** this project is not done and is still pre-alpha, it will contain bugs

# Install
**Warning backup your configs**

```sh
sh <(curl -fsSL https://raw.githubusercontent.com/Poellebob/minima-shell/refs/heads/master/install.sh)
```

## Arch

```sh
sudo pacman -Sy wireplumber libgtop bluez bluez-utils btop networkmanager \
  dart-sass wl-clipboard brightnessctl swww python upower \
  pacman-contrib power-profiles-daemon gvfs cliphist \
  hyprlock hypridle kitty ttf-jetbrains-mono-nerd qt6-wayland qt5-wayland qt5ct \
  grim slurp swappy wiremix bluetui \
  archlinux-xdg-menu xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-desktop-portal \
  jq bc git breeze breeze-gtk breeze5 papirus-icon-theme fzf zoxide
```

```sh
yay -Sy --noconfirm qt6ct-kde rose-pine-hyprcursor rose-pine-cursor quickshell-git matugen-bin afetch
```

```sh
sudo update-desktop-database
sudo mv /etc/xdg/menus/arch-applications.menu /etc/xdg/menus/applications.menu 
```

### Window Manager
#### Hyprland

```sh
yay -Sy hyprland xdg-desktop-portal-hyprland hyprpolkitagent hypremoji
```

#### Sway
```sh
sudo pacman -Sy sway
# or
yay -Sy swayfx
# or
yay -Sy scroll
```

> if you want to use Sway or Swayfx (not Scroll) add `--unsupported-gpu` to the launch command `Exec` in 
`/usr/share/wayland-sessions/sway.desktop` if you use the proprietary nvidia drivers.

**Improtent:** Sway needs enviroment variables to be set in the shell's profile to run in the correct graphics mode, theme apps and use icons.
Look at the [zprofile](https://github.com/Poellebob/minima-shell/blob/master/defaults/zprofile) or
[profile](https://github.com/Poellebob/minima-shell/blob/master/defaults/profile) used by bash, to know witch are reccomeded to set.

### Copy to home
```sh
git clone git@github.com:Poellebob/minima-shell.git --recurse-submodules
cd minima-shell
rm README.md
rm install.sh
rm -rf .git
rm -rf ./**.git*

cp -r ./config/*      ~/.config/
cp -r ./Wallpapers/   ~/

mkdir -p "$HOME/.config/minima" "$HOME/.config/quickshell"
[ ! -f "$HOME/.config/minima/hypr.conf" ] && cp ./defaults/hypr.conf "$HOME/.config/minima/"
[ ! -f "$HOME/.config/minima/sway.conf" ] && cp ./defaults/sway.conf "$HOME/.config/minima/"
[ ! -f "$HOME/.config/quickshell/config.ini" ] && cp ./defaults/config.ini "$HOME/.config/quickshell/"

chmod +x ~/.config/quickshell/scripts/generate-colors.sh
chmod +x ~/.config/quickshell/scripts/sysfetch.sh
chmod +x ~/.config/hypr/genkeys.sh
chmod +x ~/.config/hypr/set-xft-dpi.sh
chmod +x ~/.config/hypr/suspend.sh

touch ~/.config/wallpaper.conf
echo $HOME/Wallpapers/botw.png > ~/.config/wallpaper.conf

sh -c ~/.config/quickshell/scripts/generate-colors.sh
```

### Shell
Minima contains bash and zsh profiles aswell as configs to make it easy to setup sway
as it needs enviroment variables from the shell.

> Other shells will work but need to be setup manually

#### zsh
```sh
sudo pacman -Sy zsh

chsh zsh
```

##### Copy the profile and rc
```sh
cp ./config/zprofile ~/.zprofile
cp ./config/zshrc ~/.zshrc
```

#### bash
```sh
sudo pacman -Sy bash

chsh bash
```

##### Copy the profile and rc
```sh
cp ./config/profile ~/.profile
cp ./config/bashrc ~/.bashrc
```

# Keybinds

## Sway/Scroll (i3-like)

> **Note:** Scroll has a few unique keybinds not available in Sway, and vice versa.

### General (Sway/Scroll)

| Keybind | Action (Sway) | Action (Scroll) |
|---------|---------------|------------------|
| `$mod + Return` | Open terminal | Open terminal |
| `$mod + b` | Open browser | Open browser |
| `$mod + e` | Open file manager | Open file manager |
| `$mod + q` | Kill focused window | Kill focused window |
| `$mod + space` | Toggle floating | Toggle floating |
| `$mod + f` | Toggle fullscreen | Toggle fullscreen |
| `$mod + Shift + s` | Toggle sticky | Toggle sticky |
| `$mod + Alt + Delete` | Lock screen (hyprlock) | Lock screen (hyprlock) |
| `$mod + v` | Open clipboard manager | Open clipboard manager |
| `$mod + d` | Open app launcher | Open app launcher |
| `$mod + Shift + c` | Reload config | Reload config |
| `$mod + Alt + l` | Tabbed layout | Set window height to 100% |
| `$mod + Alt + h` | Stacking layout | Set window height to 50% |
| `$mod + Alt + j` | Split vertical | Move window into collum on left |
| `$mod + Alt + k` | Split horizontal | Move window into collum on right |
| `$mod + a` | Split toggle | Direction mode |
| `$mod + Escape` | Default layout | - |
| `$mod + Tab` | - | Workspace overview |

### Focus Movement (vim-style)

| Keybind | Action |
|---------|--------|
| `$mod + h` | Focus left |
| `$mod + l` | Focus right |
| `$mod + k` | Focus up |
| `$mod + j` | Focus down |

### Move Windows

| Keybind | Action |
|---------|--------|
| `$mod + Ctrl + h` | Move window left |
| `$mod + Ctrl + l` | Move window right |
| `$mod + Ctrl + k` | Move window up |
| `$mod + Ctrl + j` | Move window down |

### Resize Windows

| Keybind | Action |
|---------|--------|
| `$mod + Shift + h` | Shrink width 100px |
| `$mod + Shift + l` | Grow width 100px |
| `$mod + Shift + k` | Shrink height 100px |
| `$mod + Shift + j` | Grow height 100px |

### Workspaces

| Keybind | Action |
|---------|--------|
| `$mod + 1-9, 0` | Switch to workspace 1-10 |
| `$mod + Shift + 1-0` | Move window to workspace |
| `$mod + Ctrl + Right` | Next workspace |
| `$mod + Ctrl + Left` | Previous workspace |

---

## Hyprland

### General

| Keybind | Action |
|---------|--------|
| `$mod + Return` | Open terminal |
| `$mod + Q` | Kill focused window |
| `$mod + E` | Open file manager |
| `$mod + B` | Open browser |
| `$mod + Space` | Toggle floating |
| `$mod + F` | Toggle fullscreen |
| `$mod + Alt + Delete` | Lock screen |
| `$mod + C` | Copy window class to clipboard |
| `$mod + V` | Open clipboard manager |
| `$mod + D` | Open app launcher |
| `XF86PowerOff` | Open logout menu |

### Workspaces

| Keybind | Action |
|---------|--------|
| `$mod + 1-9, 0` | Switch to workspace 1-10 |
| `$mod + Shift + 1-0` | Move window to workspace |
| `$mod + Ctrl + Right` | Next workspace |
| `$mod + Ctrl + Left` | Previous workspace |

### Focus Movement

| Keybind | Action |
|---------|--------|
| `$mod + H` | Focus left |
| `$mod + L` | Focus right |
| `$mod + K` | Focus up |
| `$mod + J` | Focus down |

### Move Windows

| Keybind | Action |
|---------|--------|
| `$mod + Ctrl + H` | Move window left |
| `$mod + Ctrl + L` | Move window right |
| `$mod + Ctrl + K` | Move window up |
| `$mod + Ctrl + J` | Move window down |

### Resize Windows

| Keybind | Action |
|---------|--------|
| `$mod + Shift + H` | Shrink width 100px |
| `$mod + Shift + L` | Grow width 100px |
| `$mod + Shift + K` | Shrink height 100px |
| `$mod + Shift + J` | Grow height 100px |

### Mouse Bindings

| Keybind | Action |
|---------|--------|
| `$mod + Left Click` | Move window |
| `$mod + Right Click` | Resize window |

### Screenshots

| Keybind | Action |
|---------|--------|
| `Print` | Screenshot selection → clipboard |
| `Shift + Print` | Screenshot fullscreen → clipboard |
| `$mod + Print` | Screenshot selection → edit in swappy |
| `$mod + Shift + Print` | Screenshot fullscreen → edit in swappy |

### Multimedia

| Keybind | Action |
|---------|--------|
| `XF86AudioRaiseVolume` | Volume up 5% |
| `XF86AudioLowerVolume` | Volume down 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Brightness up 10% |
| `XF86MonBrightnessDown` | Brightness down 10% |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `XF86AudioPlay/Pause` | Play/Pause |

# Configuration

## Sway/Scroll

### Screen

```swayconfig
# display definitions
output DP-1 {
    res 1920x1080
    position 0 0
    scale 1.0
}

output HDMI-A-1 {
    res 1920x1080
    position -1920 0
    scale 1.0
}

# define workspases for screens
workspace 1 output DP-1
workspace 10 output HDMI-A-1

exec swaymsg workspace 1
exec swaymsg workspace 10
```

### Make a app workspace

This will be shown in the pager

```swayconfig
set $ws "stremio" # name that will be shown in the pager

for_window [app_id="com.stremio.stremio"] move to workspace $ws

# force fullscreen
for_window [app_id="com.stremio.stremio"] fullscreen enable
```

## Hyprland

### Screen

```hyprlang
$primarymonitor = ,preferred,auto,1
monitor = ,preferred,auto,1
```

the monitors id goes before the first comma, 
if left blank like in the example it applys to all monitors.

$primarymonitor is used by minimashell to set xwayland scaing 
and follows the same syntax of hyprlands monitors.

### Special workspaces

> this might not work currently because hyprland broke this recently

```hyprlang

bind = $mainMod, M, togglespecialworkspace, Discord

workspace = special:Discord

windowrule {
  name = discord
  workspace = special:Discord
  match:class = ^(WebCord|discord-canary|discord)$
}

exec-once = /usr/bin/discord
```
