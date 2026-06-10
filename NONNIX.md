# Non-Nix Setup Guide

This guide covers manual installation without Nix/Flakes.

**Warning:** Backup your configs first.

## Arch Linux Installation

### Core Packages

```sh
sudo pacman -Sy wireplumber libgtop bluez bluez-utils btop networkmanager \
  dart-sass wl-clipboard brightnessctl awww python upower \
  pacman-contrib power-profiles-daemon gvfs cliphist \
  hyprlock hypridle kitty ttf-jetbrains-mono-nerd qt6-wayland qt5-wayland qt5ct \
  grim slurp swappy wiremix bluetui polkit-kde-agent \
  archlinux-xdg-menu xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-desktop-portal \
  jq bc git breeze breeze-gtk breeze5 papirus-icon-theme fzf zoxide
```

### AUR Packages

```sh
yay -Sy --noconfirm qt6ct-kde rose-pine-hyprcursor rose-pine-cursor quickshell-git matugen-bin afetch
```

### Desktop Database Setup

```sh
sudo update-desktop-database
sudo mv /etc/xdg/menus/arch-applications.menu /etc/xdg/menus/applications.menu 
```

## Window Manager Installation

### Sway / SwayFX / Scroll

```sh
sudo pacman -Sy sway
# or
yay -Sy swayfx
# or
yay -Sy scroll
```

> If using Sway or Swayfx with proprietary NVIDIA drivers, add `--unsupported-gpu` to the `Exec` in `/usr/share/wayland-sessions/sway.desktop`.

**Important:** Sway needs environment variables set in your shell profile. See [zprofile](https://github.com/Poellebob/minima-shell/blob/master/defaults/zprofile) or [profile](https://github.com/Poellebob/minima-shell/blob/master/defaults/profile) for recommended variables.

## Copy to Home

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
[ ! -f "$HOME/.config/minima/sway.conf" ] && cp ./defaults/sway.conf "$HOME/.config/minima/"
[ ! -f "$HOME/.config/quickshell/config.ini" ] && cp ./defaults/config.ini "$HOME/.config/quickshell/"

chmod +x ~/.config/quickshell/scripts/generate-colors.sh

touch ~/.config/wallpaper.conf
echo $HOME/Wallpapers/botw.png > ~/.config/wallpaper.conf

sh -c ~/.config/quickshell/scripts/generate-colors.sh
```

## Shell Setup

Minima contains bash and zsh profiles along with configs to set up sway correctly (requires environment variables from the shell).

> Other shells will work but need manual setup.

### zsh

```sh
sudo pacman -Sy zsh

chsh zsh
```

Copy the profile and rc:

```sh
cp ./config/zprofile ~/.zprofile
cp ./config/zshrc ~/.zshrc
```

### bash

```sh
sudo pacman -Sy bash

chsh bash
```

Copy the profile and rc:

```sh
cp ./config/profile ~/.profile
cp ./config/bashrc ~/.bashrc
```
