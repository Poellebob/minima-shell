# Install


# Manual

```sh
sudo pacman -Syu wireplumber libgtop bluez bluez-utils btop networkmanager dart-sass wl-clipboard brightnessctl swww python upower pacman-contrib power-profiles-daemon gvfs cliphist hyprland hyprlock hypridle rofi-wayland kitty ttf-jetbrains-mono-nerd qt6-wayland qt5-wayland qt5ct grim slurp swappy wiremix bluetui archlinux-xdg-menu xdg-desktop-portal-hyprland jq bc hyprpolkitagent git zsh
```

```sh
yay -S --noconfirm qt6ct-kde rose-pine-hyprcursor rose-pine-cursor quickshell-git matugen-bin
```

```sh
sudo update-desktop-database
sudo mv /etc/xdg/menus/arch-applications.menu /etc/xdg/menus/applications.menu 
```

**Warning backup your configs**
```sh
git clone git@github.com:Poellebob/minima-shell.git
cd minima-shell
rm README.md
rm install.sh

cp ./* ~

chmod +x ~/.config/quickshell/scripts/generate-colors.sh
chmod +x ~/.config/quickshell/scripts/sysfetch.sh
chmod +x ~/.config/hypr/genkeys.sh
chmod +x ~/.config/hypr/set-xft-dpi.sh
chmod +x ~/.config/hypr/suspend.sh

touch ~/.config/hypr/wallpaper.conf
echo $HOME/Wallpaper/botw.png > ~/.config/hypr/wallpaper.conf
touch ~/.config/hypr/config.conf
mv defaults/hypr.conf ~/.config/hypr/config.conf

sh -c ~/.config/quickshell/scripts/generate-colors.sh
```
