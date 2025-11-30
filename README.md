# Install
**Warning backup your configs**
# minima-shell

minima-shell is a userspace shell and a hyprland config in one.

**warning:** this project is not done and is still pre-alpha, it will contain

## Manual

```sh
sudo pacman -Syu wireplumber libgtop bluez bluez-utils btop networkmanager dart-sass wl-clipboard brightnessctl swww python upower pacman-contrib power-profiles-daemon gvfs cliphist hyprland hyprlock hypridle rofi-wayland kitty ttf-jetbrains-mono-nerd qt6-wayland qt5-wayland qt5ct grim slurp swappy wiremix bluetui archlinux-xdg-menu xdg-desktop-portal-hyprland jq bc hyprpolkitagent git zsh breeze breese-gtk breeze5 papirus-icon-theme fzf zoxide
```

```sh
yay -S --noconfirm qt6ct-kde rose-pine-hyprcursor rose-pine-cursor quickshell-git matugen-bin afetch hypremoji
```

```sh
sudo update-desktop-database
sudo mv /etc/xdg/menus/arch-applications.menu /etc/xdg/menus/applications.menu 
```

### Copy to home
```sh
git clone git@github.com:Poellebob/minima-shell.git
cd minima-shell
rm README.md
rm install.sh
rm -rf .git
rm -rf ./**.git*

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

cp -r ./* ~

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

### virt-machine
```sh
sudo pacman -S qemu libvirt virt-manager dnsmasq bridge-utils #ebtables
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

sudo usermod -aG libvirt,video,render,kvm $(whoami)

sudo virsh net-start default
sudo virsh net-autostart default
```
