#!/bin/bash

set -e

detect_distro() {
    if command -v pacman &>/dev/null; then
        DISTRO="arch"
    elif command -v apt &>/dev/null; then
        DISTRO="debian"
    elif command -v dnf &>/dev/null; then
        DISTRO="fedora"
    elif command -v zypper &>/dev/null; then
        DISTRO="opensuse"
    else
        DISTRO="unknown"
    fi
}

detect_aur_helper() {
  if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
    return
  fi

  if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
    return
  fi

  echo "Installing yay..."

  local prev="$PWD"
  local dir
  dir=$(mktemp -d)

  cd "$dir" || {
    echo "Failed to create temp dir"
    return 1
  }

  git clone https://aur.archlinux.org/yay.git yay/ 2>/dev/null || {
    echo "Failed to clone yay"
    cd "$prev"
    rm -rf "$dir"
    return 1
  }

  cd ./yay || {
    cd "$prev"
    rm -rf "$dir"
    return 1
  }

  makepkg -sri || {
    cd "$prev"
    rm -rf "$dir"
    return 1
  }

  cd "$prev"
  rm -rf "$dir"

  AUR_HELPER="yay"
}

DISTRO=""
WM=""
SHELL_TYPE=""
INSTALL_DEPS=""
SHELL_CONFIG=""
TEST_MODE="no"
AUR_HELPER=""

RESET=$'\033[0m'
BOLD=$'\033[1m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'

show_logo() {
    clear
    cat <<EOF
${CYAN}
                ██            ██                           
                                                            
█████████████   ██ ████████   ██ █████████████    ██████   
██    ██    ██  ██ ██     ██  ██ ██    ██    ██        ██  
██    ██    ██  ██ ██     ██  ██ ██    ██    ██   ███████                           __     __       
██    ██    ██  ██ ██     ██  ██ ██    ██    ██  ██    ██      ___  _______   ___ _/ /__  / /  ___ _
██    ██    ██  ██ ██     ██  ██ ██    ██    ██   █████ ██    / _ \/ __/ -_) / _ '/ / _ \/ _ \/ _ '/
                                                             / .__/_/  \__/  \_,_/_/ .__/_//_/\_,_/ 
                                                            /_/                   /_/                
${RESET}
EOF
}

show_warning() {
    echo -e "${YELLOW}   WARNING: Backup your configs first!${RESET}"
    echo
}

prompt_continue() {
    echo
    echo -n "Press Enter to continue..."
    read
}

wm_submenu() {
    while true; do
        show_logo
        echo "Window Manager"
        echo "============="
        echo
        echo "  1. Sway"
        echo "  2. SwayFX"
        echo "  3. Hyprland"
        echo "  4. Scroll"
        echo "  0. Back"
        echo

        echo -n "Select option [1]: "
        read wm_choice

        case "$wm_choice" in
            1|"") WM="sway" ; break ;;
            2) WM="swayfx" ; break ;;
            3) WM="hyprland" ; break ;;
            4) WM="scroll" ; break ;;
            0) return ;;
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

shell_submenu() {
    while true; do
        show_logo
        echo "Shell"
        echo "====="
        echo
        echo "  1. zsh"
        echo "  2. bash"
        echo "  0. Back"
        echo

        echo -n "Select option [1]: "
        read shell_choice

        case "$shell_choice" in
            1|"") SHELL_TYPE="zsh" ; break ;;
            2) SHELL_TYPE="bash" ; break ;;
            0) return ;;
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

shell_config_submenu() {
    while true; do
        show_logo
        echo "Shell Config"
        echo "============"
        echo
        echo "  1. Both (rc + profile)"
        echo "  2. rc only"
        echo "  3. profile only"
        echo "  4. None"
        echo "  0. Back"
        echo

        echo -n "Select option [1]: "
        read config_choice

        case "$config_choice" in
            1|"") SHELL_CONFIG="both" ; break ;;
            2) SHELL_CONFIG="rc" ; break ;;
            3) SHELL_CONFIG="profile" ; break ;;
            4) SHELL_CONFIG="none" ; break ;;
            0) return ;;
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

deps_submenu() {
    while true; do
        show_logo
        echo "Install Dependencies"
        echo "==================="
        echo
        echo "  1. Yes ($DISTRO packages)"
        echo "  2. No (configs only)"
        echo "  0. Back"
        echo

        echo -n "Select option [1]: "
        read deps_choice

        case "$deps_choice" in
            1| "") INSTALL_DEPS="yes" ; break ;;
            2) INSTALL_DEPS="no" ; break ;;
            0) return ;;
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

get_main_default() {
    if [ -z "$WM" ]; then
        echo "1"
    elif [ -z "$SHELL_TYPE" ]; then
        echo "2"
    elif [ -z "$INSTALL_DEPS" ]; then
        echo "3"
    elif [ -z "$SHELL_CONFIG" ]; then
        echo "4"
    else
        echo "5"
    fi
}

main_menu() {
    while true; do
        show_logo
        show_warning

        echo "Detected distro: $DISTRO"
        echo

        if [ "$TEST_MODE" = "yes" ]; then
            echo -e "${YELLOW}=== TEST MODE: No changes will be made ===${RESET}"
            echo
        fi

        echo "Configuration"
        echo "============"
        echo
        echo "  1. Window Manager:  ${WM:-<not set>}"
        echo "  2. Shell:          ${SHELL_TYPE:-<not set>}"
        echo "  3. Dependencies:   ${INSTALL_DEPS:-<not set>}"
        echo "  4. Shell Config:    ${SHELL_CONFIG:-<not set>}"
        echo
        echo "  5. Confirm & Install"
        echo "  6. Exit"
        echo

        local default
        default=$(get_main_default)
        local main_choice
        echo -n "Select option [$default]: "
        read main_choice

        : ${main_choice:=$default}

        case "$main_choice" in
            1) wm_submenu ;;
            2) shell_submenu ;;
            3) deps_submenu ;;
            4) shell_config_submenu ;;
            5)
                if validate_config; then
                    run_installation
                    return
                fi
                ;;
            6) exit 0 ;;
            *) echo -e "${RED}Invalid option${RESET}" ;;
        esac
    done
}

validate_config() {
    if [ -z "$WM" ]; then
        echo -e "${RED}Please select a Window Manager first${RESET}"
        echo -n "Press Enter to continue..."
        read
        return 1
    fi
    if [ -z "$SHELL_TYPE" ]; then
        echo -e "${RED}Please select a Shell first${RESET}"
        echo -n "Press Enter to continue..."
        read
        return 1
    fi
    if [ -z "$INSTALL_DEPS" ]; then
        echo -e "${RED}Please select whether to install dependencies${RESET}"
        echo -n "Press Enter to continue..."
        read
        return 1
    fi
    if [ -z "$SHELL_CONFIG" ]; then
        echo -e "${RED}Please select shell config option${RESET}"
        echo -n "Press Enter to continue..."
        read
        return 1
    fi
    return 0
}

show_nvidia_warning() {
  if ! lsmod | grep -q '^nvidia'; then
    return
  fi

  echo
  cat <<EOF
${YELLOW}
╔═══════════════════════════════════════════════════════════╗
║                     NVIDIA USERS                          ║
╠═══════════════════════════════════════════════════════════╣
║ If using proprietary NVIDIA drivers, edit:                ║
║   /usr/share/wayland-sessions/sway.desktop                ║
║                                                           ║
║ Change: Exec=sway                                         ║
║ To:     Exec=sway --unsupported-gpu                       ║
╚═══════════════════════════════════════════════════════════╝${RESET}
EOF
}

run_installation() {
    if [ "$TEST_MODE" = "yes" ]; then
        run_dry_run
        return
    fi

    show_logo
    echo "Installing..."
    echo

    if [ "$INSTALL_DEPS" = "yes" ]; then
        case "$DISTRO" in
            arch) install_deps_arch ;;
            debian) echo "Debian support not implemented yet" ;;
            fedora) echo "Fedora support not implemented yet" ;;
            opensuse) echo "openSUSE support not implemented yet" ;;
            *) echo "Unknown distro: $DISTRO" ;;
        esac
    fi

    install_configs

    case "$WM" in
        sway)     install_wm_sway ;;
        swayfx)   install_wm_swayfx ;;
        hyprland) install_wm_hyprland ;;
        scroll)  install_wm_scroll ;;
    esac

    case "$SHELL_TYPE" in
        zsh) install_shell_zsh ;;
        bash) install_shell_bash ;;
    esac

    show_logo
    echo -e "${GREEN}Installation complete!${RESET}"
    echo

    if {
        [ "$SHELL_CONFIG" = "rc" ] || [ "$SHELL_CONFIG" = "none" ]
    } && {
        [ "$WM" = "sway" ] || [ "$WM" = "swayfx" ] || [ "$WM" = "scroll" ]
    }; then
        echo "${YELLOW}Sway needs some environment variables to be set in the shell profile to show icons and theme system apps.${RESET}"
        echo "${YELLOW}Read https://github.com/Poellebob/minima-shell#sway to know which variables to set"
    fi

    if [ "$WM" = "sway" ] || [ "$WM" = "swayfx" ]; then
        show_nvidia_warning
    fi

    echo
    echo -n "Press Enter to exit..."
    read
    exit 0
}

run_dry_run() {
    show_logo
    show_warning

    echo "=== TEST MODE (DRY RUN) ==="
    echo
    echo "Variables set:"
    echo "  DISTRO= $DISTRO"
    echo "  WM= $WM"
    echo "  SHELL= $SHELL_TYPE"
    echo "  INSTALL_DEPS= $INSTALL_DEPS"
    echo

    echo "Would run:"
    echo "-----------"

    if [ "$INSTALL_DEPS" = "yes" ]; then
        case "$DISTRO" in
            arch)
                echo "- pacman: wireplumber libgtop bluez bluez-utils btop networkmanager ..."
                echo "- pacman: base-devel (fakeroot, debugedit, etc.)"
                echo "- git clone + makepkg: $AUR_HELPER (AUR helper)"
                echo "- $AUR_HELPER: qt6ct-kde rose-pine-hyprcursor rose-pine-cursor google-breakpad quickshell matugen-bin afetch"
                echo "- sudo: update-desktop-database, mv arch-applications.menu"
                ;;
            debian)
                echo "- apt: [packages not configured]"
                ;;
            fedora)
                echo "- dnf: [packages not configured]"
                ;;
            opensuse)
                echo "- zypper: [packages not configured]"
                ;;
            *)
                echo "- No package manager detected"
                ;;
        esac
    else
        echo "- Skip: dependency installation"
    fi

    case "$WM" in
        sway)     echo "- pacman: sway" ;;
        swayfx)   echo "- $AUR_HELPER: swayfx" ;;
        hyprland) echo "- $AUR_HELPER: hyprland xdg-desktop-portal-hyprland hyprpolkitagent hypremoji" ;;
        scroll)   echo "- $AUR_HELPER: scroll" ;;
    esac

    case "$SHELL_TYPE" in
        zsh)  echo "- pacman: zsh" ;;
        bash) echo "- pacman: bash" ;;
    esac

    echo "- cp: config/* -> ~/.config/"
    echo "- cp: Wallpapers/ -> ~/"
    echo "- chmod +x: various scripts"
    echo "- generate-colors.sh"
    echo

    if [ "$WM" = "sway" ] || [ "$WM" = "swayfx" ]; then
        show_nvidia_warning
    fi

    echo "=== END TEST MODE ==="
    echo
    echo -n "Press Enter to exit..."
    read
    exit 0
}

build_aur_pkg() {
    local pkg="$1"
    echo "Installing $pkg from AUR..."
    sh -c "$AUR_HELPER -S --needed --noconfirm $pkg"
}

install_deps_arch() {
    echo "Installing base dependencies (pacman)..."
    sudo pacman -Sy --needed wireplumber libgtop bluez bluez-utils btop networkmanager jemalloc\
      dart-sass wl-clipboard brightnessctl swww python upower neovim\
      pacman-contrib power-profiles-daemon gvfs cliphist \
      hyprlock hypridle kitty ttf-jetbrains-mono-nerd qt6-wayland qt5-wayland qt5ct \
      grim slurp swappy wiremix bluetui \
      archlinux-xdg-menu xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-desktop-portal \
      jq bc git breeze breeze-gtk breeze5 papirus-icon-theme fzf zoxide

    echo "Installing AUR build dependencies..."
    sudo pacman -Sy --needed base-devel

    detect_aur_helper

    echo "Installing AUR packages..."
    build_aur_pkg qt6ct-kde
    build_aur_pkg rose-pine-hyprcursor
    build_aur_pkg rose-pine-cursor
    build_aur_pkg google-breakpad
    build_aur_pkg quickshell
    build_aur_pkg matugen-bin
    build_aur_pkg afetch

    echo "Running desktop database setup..."
    sudo update-desktop-database
    sudo mv /etc/xdg/menus/arch-applications.menu /etc/xdg/menus/applications.menu 2>/dev/null || true
}

install_wm_sway() {
    echo "Installing Sway..."
    sudo pacman -Sy --needed sway
}

install_wm_swayfx() {
    echo "Installing SwayFX..."
    build_aur_pkg swayfx
}

install_wm_hyprland() {
    echo "Installing Hyprland..."
    build_aur_pkg hyprland
    build_aur_pkg xdg-desktop-portal-hyprland
    build_aur_pkg hyprpolkitagent
    build_aur_pkg hypremoji
}

install_wm_scroll() {
    echo "Installing Scroll..."
    build_aur_pkg scroll
}

install_shell_zsh() {
    echo "Installing zsh..."
    sudo pacman -Sy --needed zsh
    echo "To change shell, run: chsh zsh"
    chsh -s /usr/bin/zsh || true
}

install_shell_bash() {
    echo "Installing bash..."
    sudo pacman -Sy --needed bash
    echo "To change shell, run: chsh bash"
    chsh -s /usr/bin/bash || true
}

install_configs() {
    local prev=$PWD
    local dir=$(mktemp -d)
    git clone https://github.com/Poellebob/minima-shell.git "$dir" --recurse-submodules
    cd $dir

    : ${SHELL_CONFIG:=both}

    echo "Copying configs to home..."
    cp -r ./config/* ~/.config/ 2>/dev/null || true
    cp -r ./Wallpapers/ ~/ 2>/dev/null || true

    mkdir -p "$HOME/.config/minima" "$HOME/.config/quickshell"
    [ ! -f "$HOME/.config/minima/hypr.conf" ] && cp ./defaults/hypr.conf "$HOME/.config/minima/" 2>/dev/null || true
    [ ! -f "$HOME/.config/minima/sway.conf" ] && cp ./defaults/sway.conf "$HOME/.config/minima/" 2>/dev/null || true
    [ ! -f "$HOME/.config/quickshell/config.ini" ] && cp ./defaults/config.ini "$HOME/.config/quickshell/" 2>/dev/null || true

    case "$SHELL_CONFIG" in
        both)
            cp ./config/zprofile ~/.zprofile 2>/dev/null || true
            cp ./config/zshrc ~/.zshrc 2>/dev/null || true
            cp ./config/profile ~/.profile 2>/dev/null || true
            cp ./config/bashrc ~/.bashrc 2>/dev/null || true
            ;;
        rc)
            cp ./config/zshrc ~/.zshrc 2>/dev/null || true
            cp ./config/bashrc ~/.bashrc 2>/dev/null || true
            ;;
        profile)
            cp ./config/zprofile ~/.zprofile 2>/dev/null || true
            cp ./config/profile ~/.profile 2>/dev/null || true
            ;;
        none)
            ;;
    esac

    chmod +x ~/.config/quickshell/scripts/generate-colors.sh 2>/dev/null || true
    chmod +x ~/.config/quickshell/scripts/sysfetch.sh 2>/dev/null || true
    chmod +x ~/.config/hypr/genkeys.sh 2>/dev/null || true
    chmod +x ~/.config/hypr/set-xft-dpi.sh 2>/dev/null || true
    chmod +x ~/.config/hypr/suspend.sh 2>/dev/null || true
    chmod +x ~/.config/sway/set-xft-dpi.sh 2>/dev/null || true
    chmod +x ~/.config/scroll/set-xft-dpi.sh 2>/dev/null || true

    touch ~/.config/wallpaper.conf
    [ ! -s ~/.config/wallpaper.conf ] && echo "$HOME/Wallpapers/botw.png" > ~/.config/wallpaper.conf

    sh -c "$HOME/.config/quickshell/scripts/generate-colors.sh" 2>/dev/null || true
    
    cd $prev
    rm -rf $dir
}

case "$1" in
    --test)
        TEST_MODE="yes"
        detect_distro
        main_menu
        ;;
    *)
        detect_distro
        main_menu
        ;;
esac
