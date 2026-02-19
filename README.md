# minima-shell

minima-shell is a userspace shell and a [scroll](https://github.com/dawsers/scroll/) and [hyprland](https://hypr.land/) config in one.

Even tho it it supports hyprland fully it is not as featrue complete as scroll.

i3 and sway is also supported but a config is not provided yet.

**Warning:** this project is not done and is still pre-alpha, it will contain bugs

# Install
**Warning backup your configs**

## Arch

```sh
sudo pacman -Sy wireplumber libgtop bluez bluez-utils btop networkmanager \
  dart-sass wl-clipboard brightnessctl swww python upower \
  pacman-contrib power-profiles-daemon gvfs cliphist \
  hyprlock hypridle kitty ttf-jetbrains-mono-nerd qt6-wayland qt5-wayland qt5ct \
  grim slurp swappy wiremix bluetui \
  archlinux-xdg-menu xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-desktop-portal \
  jq bc git zsh breeze breeze-gtk breeze5 papirus-icon-theme fzf zoxide
```

```sh
yay -Sy --noconfirm qt6ct-kde rose-pine-hyprcursor rose-pine-cursor quickshell-git matugen-bin afetch hypremoji
```

```sh
sudo update-desktop-database
sudo mv /etc/xdg/menus/arch-applications.menu /etc/xdg/menus/applications.menu 
```

### hyprland

```sh
sudo pacman -Sy hyprland xdg-desktop-portal-hyprland hyprpolkitagent 
```

### scroll

```sh
yay -Sy scroll
```

### Copy to home
```sh
git clone git@github.com:Poellebob/minima-shell.git --recurse-submodules
cd minima-shell
rm README.md
rm install.sh
rm -rf .git
rm -rf ./**.git*

cp -r ./config/*      ~/.config/
cp -r ./zsh-defer/*   ~/.zsh-defer/
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
mv defaults/hypr.conf ~/.config/hypr/config.conf

sh -c ~/.config/quickshell/scripts/generate-colors.sh
```

### zsh theme
```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

### virt-machine
```sh
sudo pacman -S qemu libvirt virt-manager dnsmasq bridge-utils #ebtables
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

sudo usermod -aG libvirt,video,render,kvm $(whoami)

sudo virsh net-start default
sudo virsh net-autostart default
```

# Sway/Scroll/i3

## Screen

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

## Make a app workspace

This will be shown in the pager

```swayconfig
set $ws "stremio" # name that will be shown in the pager

for_window [app_id="com.stremio.stremio"] move to workspace $ws

# force fullscreen
for_window [app_id="com.stremio.stremio"] fullscreen enable
```
