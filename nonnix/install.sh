#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd || true)"
readonly DEFAULT_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly DEFAULT_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly DEFAULT_BIN_HOME="$HOME/.local/bin"
readonly BUILD_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/minima-shell/build"
readonly MINIMA_REPOSITORY="${MINIMA_REPOSITORY:-https://github.com/Poellebob/minima-shell.git}"
readonly MINIMA_REF="${MINIMA_REF:-master}"
readonly MINIMA_ARCHIVE_URL="${MINIMA_ARCHIVE_URL:-https://github.com/Poellebob/minima-shell/archive/refs/heads/${MINIMA_REF}.tar.gz}"

data_home="$DEFAULT_DATA_HOME"
config_home="$DEFAULT_CONFIG_HOME"
bin_home="$DEFAULT_BIN_HOME"
dry_run=false
check_only=false
show_menu=true
assume_yes=false
distro=""
ubuntu_codename=""
declare -A selected=(
  [calculator]=true
  [clipboard]=true
  [wallpapers]=false
  [colors]=true
  [wallpaper-engine]=false
  [font]=true
)
declare -A package_seen=()
native_packages=()
source_actions=()
rustup_command=""
aur_packages=()
menu_active=false
generated_config=""
config_backup=""
temporary_dirs=()

cleanup() {
  local directory
  for directory in "${temporary_dirs[@]}"; do
    if [[ -d "$directory" ]]; then
      rm -rf "$directory"
    fi
  done
}
trap cleanup EXIT

usage() {
  cat <<'EOF'
Usage: ./nonnix/install.sh [options]

Install the Minima shell. Opens a configuration menu in an interactive terminal.

Options:
  --dry-run             Print planned changes without writing files.
  --check               Check runtime and optional dependencies only.
  --distro NAME         Override detection: arch, fedora, or debian.
  --with FEATURE        Select a feature without the menu; may be repeated.
                        Features: calculator, clipboard, wallpapers, colors,
                        wallpaper-engine, font.
  --no-menu             Do not show the feature menu.
  --yes                 Confirm dependency and third-party actions noninteractively.
  --data-home PATH      Override XDG data home (default: ~/.local/share).
  --config-home PATH    Override XDG config home (default: ~/.config).
  --bin-home PATH       Override launcher directory (default: ~/.local/bin).
  -h, --help            Show this help.

QuickShell and its Qt runtime are required. Native packages are installed only
after confirmation. Third-party repositories and builds require separate consent.
EOF
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

note() {
  printf '%s\n' "$*"
}

warn() {
  local yellow='' reset=''
  if [[ -t 1 && "${TERM:-dumb}" != dumb && ! -v NO_COLOR ]]; then
    yellow=$'\033[1;33m'
    reset=$'\033[0m'
  fi
  printf '%sWARNING: %s%s\n' "$yellow" "$*" "$reset"
}

run() {
  if "$dry_run"; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

confirm() {
  local prompt="$1"
  local answer

  if "$assume_yes" || "$dry_run"; then
    return 0
  fi
  read -r -p "$prompt [y/N] " answer
  [[ "$answer" == "y" || "$answer" == "Y" || "$answer" == "yes" || "$answer" == "YES" ]]
}

set_feature() {
  [[ -v "selected[$1]" ]] || fail "unknown feature: $1"
  selected["$1"]=true
}

feature_name() {
  case "$1" in
    calculator) printf 'Calculator (qalc)' ;;
    clipboard) printf 'Clipboard history (cliphist, wl-clipboard)' ;;
    wallpapers) printf 'Static wallpapers (awww)' ;;
    colors) printf 'Wallpaper palette generation (matugen)' ;;
    wallpaper-engine) printf 'Wallpaper Engine (linux-wallpaperengine)' ;;
    font) printf 'JetBrainsMono Nerd Font' ;;
  esac
}

feature_state() {
  if "${selected[$1]}"; then
    printf 'selected'
  else
    printf 'not selected'
  fi
}

toggle_feature() {
  if "${selected[$1]}"; then
    selected["$1"]=false
  else
    selected["$1"]=true
  fi
}

detect_distro() {
  [[ -r /etc/os-release ]] || return
  # shellcheck disable=SC1091
  . /etc/os-release
  ubuntu_codename="${UBUNTU_CODENAME:-}"
  if [[ "${ID:-}" == ubuntu ]]; then
    ubuntu_codename="${VERSION_CODENAME:-$ubuntu_codename}"
  fi
  [[ -z "$distro" ]] || return 0
  case "${ID:-}" in
    arch|manjaro|endeavouros) distro=arch ;;
    fedora) distro=fedora ;;
    debian|ubuntu|linuxmint|pop) distro=debian ;;
  esac
}

choose_distro() {
  local choice
  while true; do
    menu_header 'Package Manager'
    note "  Current family: ${distro:-not selected}"
    note
    note '  1. Arch Linux'
    note '  2. Fedora'
    note '  3. Debian / Ubuntu'
    note '  0. Back'
    note
    read -r -p 'Select option [0]: ' choice || return 0
    case "$choice" in
      1) distro=arch; return ;;
      2) distro=fedora; return ;;
      3) distro=debian; return ;;
      0|"") return ;;
      *) note 'Enter 0, 1, 2, or 3.'; menu_pause ;;
    esac
  done
}

check_command() {
  local command_name="$1"
  local kind="$2"

  if command -v "$command_name" >/dev/null 2>&1; then
    printf 'found %-24s (%s)\n' "$command_name" "$kind"
  else
    printf 'missing %-22s (%s)\n' "$command_name" "$kind"
  fi
}

check_dependencies() {
  note 'Dependency check:'
  check_command qs 'required QuickShell runtime'
  check_command systemd-inhibit 'required power-key inhibitor'
  check_command loginctl 'session actions'
  check_command ip 'network status fallback'
  check_command nmcli 'network controls (NetworkManager)'
  check_command qalc 'optional calculator'
  check_command wl-copy 'optional clipboard support'
  check_command wl-paste 'optional clipboard support'
  check_command cliphist 'optional clipboard history'
  check_command awww 'optional static wallpapers'
  check_command awww-daemon 'optional static wallpapers'
  check_command matugen 'optional palette generation'
  check_command linux-wallpaperengine 'optional animated wallpapers'
  check_command fc-cache 'optional font cache refresh'
}

source_tree_ready() {
  [[ -f "$SOURCE_ROOT/shell/shell.qml" && -f "$SOURCE_ROOT/colors.json" && -f "$SOURCE_ROOT/nonnix/config.json" ]]
}

bootstrap_source_tree() {
  local source_dir
  source_tree_ready && return

  if "$dry_run"; then
    SOURCE_ROOT='<downloaded Minima source>'
    if command -v git >/dev/null 2>&1; then
      note "+ git clone --depth 1 --branch $MINIMA_REF $MINIMA_REPOSITORY <temporary-source>"
    else
      note "+ curl --fail --location --output <temporary-source>/source.tar.gz $MINIMA_ARCHIVE_URL"
      note '+ tar -xzf <temporary-source>/source.tar.gz --strip-components=1 -C <temporary-source>'
    fi
    return
  fi

  source_dir="$(mktemp -d "${TMPDIR:-/tmp}/minima-shell-source.XXXXXX")"
  temporary_dirs+=("$source_dir")
  if command -v git >/dev/null 2>&1; then
    run git clone --depth 1 --branch "$MINIMA_REF" "$MINIMA_REPOSITORY" "$source_dir"
  else
    command -v curl >/dev/null 2>&1 || fail 'git or curl is required when installing from the remote one-line command'
    command -v tar >/dev/null 2>&1 || fail 'tar is required when git is unavailable'
    run curl --fail --location --output "$source_dir/source.tar.gz" "$MINIMA_ARCHIVE_URL"
    run tar -xzf "$source_dir/source.tar.gz" --strip-components=1 -C "$source_dir"
    run rm "$source_dir/source.tar.gz"
  fi
  SOURCE_ROOT="$source_dir"
  source_tree_ready || fail 'downloaded Minima source is incomplete'
}

add_native_package() {
  local package="$1"
  if [[ ! -v "package_seen[$package]" ]]; then
    package_seen["$package"]=1
    native_packages+=("$package")
  fi
}

add_source_action() {
  source_actions+=("$1")
}

prepare_actions() {
  local package
  local runtime_packages=()
  native_packages=()
  source_actions=()
  aur_packages=()
  package_seen=()

  case "$distro" in
    arch)
      runtime_packages=(
        quickshell qt6-declarative qt6-wayland qt6-svg qt6-imageformats
        bash coreutils findutils systemd iproute2
      )
      ;;
    fedora)
      runtime_packages=(
        quickshell qt6-qtdeclarative qt6-qtwayland qt6-qtsvg qt6-qtimageformats
        bash coreutils findutils systemd iproute
      )
      ;;
    debian)
      runtime_packages=(
        qml6-module-qtqml qml6-module-qtqml-models qml6-module-qtqml-workerscript
        qml6-module-qtquick qml6-module-qtquick-layouts qml6-module-qtquick-controls
        qml6-module-qtquick-templates qml6-module-qtquick-window
        qt6-wayland libqt6svg6 qt6-image-formats-plugins
        bash coreutils findutils systemd iproute2
      )
      if [[ -n "$ubuntu_codename" ]]; then
        if ! command -v qs >/dev/null 2>&1; then
          runtime_packages+=(software-properties-common curl ca-certificates)
          add_source_action quickshell-ppa
        fi
      else
        runtime_packages+=(quickshell)
      fi
      ;;
  esac
  for package in "${runtime_packages[@]}"; do
    add_native_package "$package"
  done

  if [[ "$distro" != arch ]] && { "${selected[wallpapers]}" || "${selected[colors]}"; }; then
    add_native_package curl
    add_native_package ca-certificates
    case "$distro" in
      debian) add_native_package build-essential ;;
      fedora) add_native_package gcc ;;
    esac
    add_source_action rust-toolchain
  fi

  if "${selected[calculator]}"; then
    add_native_package wl-clipboard
    case "$distro" in
      arch) add_native_package libqalculate ;;
      fedora) add_native_package qalculate ;;
      debian) add_native_package qalc ;;
    esac
  fi

  if "${selected[clipboard]}"; then
    add_native_package wl-clipboard
    add_native_package cliphist
  fi

  if "${selected[wallpapers]}" || "${selected[wallpaper-engine]}"; then
    add_native_package psmisc
  fi

  if "${selected[wallpapers]}"; then
    if [[ "$distro" == arch ]]; then
      add_native_package awww
    else
      add_native_package git
      case "$distro" in
        debian)
          for package in pkg-config liblz4-dev libwayland-dev wayland-protocols libxkbcommon-dev; do
            add_native_package "$package"
          done
          ;;
        fedora)
          for package in pkgconf-pkg-config lz4-devel wayland-devel wayland-protocols-devel libxkbcommon-devel; do
            add_native_package "$package"
          done
          ;;
      esac
      add_source_action awww
    fi
  fi

  if "${selected[colors]}"; then
    if [[ "$distro" == arch ]]; then
      add_native_package matugen
    else
      add_source_action matugen
    fi
  fi

  if "${selected[wallpaper-engine]}"; then
    if [[ "$distro" == arch ]]; then
      aur_packages+=(linux-wallpaperengine-git)
    else
      add_native_package git
      add_native_package cmake
      if [[ "$distro" == debian ]]; then
        local debian_engine_packages=(
          build-essential libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev
          libgl-dev libglew-dev freeglut3-dev libsdl2-dev liblz4-dev
          libavcodec-dev libavformat-dev libavutil-dev libswscale-dev
          libxxf86vm-dev libglm-dev libglfw3-dev libmpv-dev mpv libpulse-dev
          libfftw3-dev libfreetype-dev
        )
        local package
        for package in "${debian_engine_packages[@]}"; do
          add_native_package "$package"
        done
      else
        local fedora_engine_packages=(
          gcc gcc-c++ libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel
          mesa-libGL-devel glew-devel freeglut-devel SDL2-devel lz4-devel ffmpeg
          ffmpeg-free-devel libXxf86vm-devel glm-devel glfw-devel mpv mpv-devel
          pulseaudio-libs-devel fftw-devel gmp-devel
        )
        local package
        for package in "${fedora_engine_packages[@]}"; do
          add_native_package "$package"
        done
      fi
      add_source_action wallpaper-engine
    fi
  fi

  if "${selected[font]}"; then
    if [[ "$distro" == arch ]]; then
      add_native_package ttf-jetbrains-mono-nerd
    else
      add_native_package curl
      add_native_package tar
      add_native_package fontconfig
      case "$distro" in
        debian) add_native_package xz-utils ;;
        fedora) add_native_package xz ;;
      esac
      add_source_action font
    fi
  fi
}

review_actions() {
  local feature count=0
  note
  note "Distribution: $distro"
  note 'Required: QuickShell, Qt QML/Quick Controls, Wayland, SVG/image support, and shell utilities.'
  if [[ "$distro" == fedora ]]; then
    note 'QuickShell uses enabled Fedora repositories; if unavailable, the errornointernet/quickshell COPR requires separate consent.'
  fi
  note 'Selected optional features:'
  for feature in calculator clipboard wallpapers colors wallpaper-engine font; do
    if "${selected[$feature]}"; then
      note "  - $(feature_name "$feature")"
      count=$((count + 1))
    fi
  done
  ((count)) || note '  None (required runtime only).'
  if ! "${selected[font]}"; then
    warn 'Skipping the font can break UI icons and layout. Only skip it if JetBrainsMono Nerd Font is already installed.'
  fi
  if [[ -e "$config_home/minima/config.json" || -e "$config_home/minima/matugen.toml" ]]; then
    warn 'Existing config.json and matugen.toml will be replaced; .bak files keep only the latest backup.'
  fi

  if ((${#native_packages[@]})); then
    note 'Native packages:'
    printf '  %s\n' "${native_packages[*]}"
  fi

  if ((${#aur_packages[@]})); then
    note 'Arch AUR packages (requires an existing yay or paru installation):'
    printf '  %s\n' "${aur_packages[*]}"
  fi

  if ((${#source_actions[@]})); then
    note 'Third-party source/download actions:'
    local action
    for action in "${source_actions[@]}"; do
      case "$action" in
        quickshell-ppa) warn "Add ppa:avengemedia/danklinux for Ubuntu $ubuntu_codename and install QuickShell (system-wide)." ;;
        rust-toolchain) note '  - Install/update stable Rust through rustup (https://sh.rustup.rs); leave shell profiles and the default toolchain unchanged.' ;;
        awww) note '  - Clone Codeberg awww and install with Cargo into ~/.local/bin.' ;;
        matugen) note '  - Download the matugen crate with Cargo into ~/.local/bin.' ;;
        wallpaper-engine) note '  - Clone GitHub linux-wallpaperengine and compile it into the selected bin directory.' ;;
        font) note '  - Download JetBrainsMono Nerd Font from the Nerd Fonts latest release.' ;;
      esac
    done
  fi
}

install_native_packages() {
  ((${#native_packages[@]})) || return 0
  command -v sudo >/dev/null 2>&1 || fail 'sudo is required to install native packages'

  case "$distro" in
    arch)
      run sudo pacman -S --needed "${native_packages[@]}"
      ;;
    fedora)
      if "$dry_run"; then
        note 'If quickshell is unavailable, offer to install the matching DNF COPR plugin and enable errornointernet/quickshell.'
      elif ! dnf -q list --available quickshell >/dev/null 2>&1 && ! dnf -q list --installed quickshell >/dev/null 2>&1; then
        warn 'QuickShell was not found in enabled Fedora repositories. The upstream-documented fallback is the third-party errornointernet/quickshell COPR.'
        confirm 'Enable this COPR to install the required QuickShell runtime?' || fail 'QuickShell is required; installation cancelled'
        local dnf_plugins=dnf-plugins-core
        if [[ "$(dnf --version)" == *dnf5* ]]; then
          dnf_plugins=dnf5-plugins
        fi
        run sudo dnf --setopt=install_weak_deps=False install "$dnf_plugins"
        run sudo dnf copr enable -y errornointernet/quickshell
      fi
      run sudo dnf --setopt=install_weak_deps=False install "${native_packages[@]}"
      ;;
    debian)
      run sudo apt-get update
      run apt-get --simulate install --no-install-recommends "${native_packages[@]}"
      run sudo apt-get install --no-install-recommends "${native_packages[@]}"
      ;;
  esac
}

require_command() {
  local command_name="$1"
  if command -v "$command_name" >/dev/null 2>&1; then
    return
  fi
  "$dry_run" && return
  fail "$command_name is required for this selected source action"
}

install_quickshell_from_ppa() {
  require_command sudo
  require_command curl
  require_command add-apt-repository
  warn "This adds the third-party ppa:avengemedia/danklinux repository for Ubuntu $ubuntu_codename."
  if ! confirm 'Add this PPA and install QuickShell?'; then
    fail 'QuickShell is required; installation cancelled'
  fi
  if ! "$dry_run"; then
    curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location --output /dev/null \
      "https://ppa.launchpadcontent.net/avengemedia/danklinux/ubuntu/dists/$ubuntu_codename/Release" \
      || fail "could not verify the DankLinux PPA for $ubuntu_codename; no repository was added"
  fi
  run sudo add-apt-repository --yes ppa:avengemedia/danklinux
  run sudo apt-get update
  run apt-get --simulate install --no-install-recommends quickshell
  run sudo apt-get install --no-install-recommends quickshell
  if ! "$dry_run"; then
    command -v qs >/dev/null 2>&1 || fail 'QuickShell installation finished but qs is not on PATH'
  fi
}

install_rust_toolchain() {
  local installer_dir
  require_command curl
  rustup_command="${CARGO_HOME:-$HOME/.cargo}/bin/rustup"
  if command -v rustup >/dev/null 2>&1; then
    rustup_command="$(command -v rustup)"
  elif [[ ! -x "$rustup_command" ]]; then
    if "$dry_run"; then
      note '+ download https://sh.rustup.rs and run sh rustup-init.sh -y --no-modify-path --profile minimal --default-toolchain none'
    else
      installer_dir="$(mktemp -d "${TMPDIR:-/tmp}/minima-rustup.XXXXXX")"
      temporary_dirs+=("$installer_dir")
      run curl --proto '=https' --tlsv1.2 --fail --location --output "$installer_dir/rustup-init.sh" https://sh.rustup.rs
      run sh "$installer_dir/rustup-init.sh" -y --no-modify-path --profile minimal --default-toolchain none
    fi
  fi
  run "$rustup_command" toolchain install stable --profile minimal
}

install_awww_from_source() {
  local source_dir="$BUILD_ROOT/awww"
  require_command git
  if "$dry_run"; then
    note '+ git clone --depth 1 https://codeberg.org/LGFae/awww.git <build>/awww'
    note "+ $rustup_command run stable cargo install --locked --path <build>/awww/client --root $HOME/.local"
    note "+ $rustup_command run stable cargo install --locked --path <build>/awww/daemon --root $HOME/.local"
    return
  fi
  run rm -rf "$source_dir"
  run install -d "$BUILD_ROOT"
  run git clone --depth 1 https://codeberg.org/LGFae/awww.git "$source_dir"
  run "$rustup_command" run stable cargo install --locked --path "$source_dir/client" --root "$HOME/.local"
  run "$rustup_command" run stable cargo install --locked --path "$source_dir/daemon" --root "$HOME/.local"
}

install_matugen_from_source() {
  run "$rustup_command" run stable cargo install --locked matugen --root "$HOME/.local"
}

install_wallpaper_engine_from_source() {
  local source_dir="$BUILD_ROOT/linux-wallpaperengine"
  local binary="$source_dir/build/output/linux-wallpaperengine"
  require_command git
  require_command cmake
  if "$dry_run"; then
    note '+ git clone --depth 1 --recurse-submodules https://github.com/Almamu/linux-wallpaperengine.git <build>/linux-wallpaperengine'
    note '+ cmake -S <build>/linux-wallpaperengine -B <build>/linux-wallpaperengine/build -DCMAKE_BUILD_TYPE=Release'
    note '+ cmake --build <build>/linux-wallpaperengine/build'
    note "+ install -m 755 <build>/linux-wallpaperengine/build/output/linux-wallpaperengine $bin_home/linux-wallpaperengine"
    return
  fi
  run rm -rf "$source_dir"
  run install -d "$BUILD_ROOT" "$bin_home"
  run git clone --depth 1 --recurse-submodules https://github.com/Almamu/linux-wallpaperengine.git "$source_dir"
  run cmake -S "$source_dir" -B "$source_dir/build" -DCMAKE_BUILD_TYPE=Release
  run cmake --build "$source_dir/build"
  [[ -x "$binary" ]] || fail "expected Wallpaper Engine binary was not created: $binary"
  run install -m 755 "$binary" "$bin_home/linux-wallpaperengine"
}

install_font() {
  local archive="$BUILD_ROOT/JetBrainsMono.tar.xz"
  local font_dir="$data_home/fonts/JetBrainsMono"
  require_command curl
  require_command tar
  require_command fc-cache
  if "$dry_run"; then
    note '+ curl --fail --location --output <build>/JetBrainsMono.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz'
    note "+ tar -xf <build>/JetBrainsMono.tar.xz -C $font_dir"
    note "+ fc-cache -f $font_dir"
    return
  fi
  run install -d "$BUILD_ROOT" "$font_dir"
  run curl --fail --location --output "$archive" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
  run tar -xf "$archive" -C "$font_dir"
  run fc-cache -f "$font_dir"
}

install_aur_packages() {
  ((${#aur_packages[@]})) || return 0
  local helper=""
  if command -v paru >/dev/null 2>&1; then
    helper=paru
  elif command -v yay >/dev/null 2>&1; then
    helper=yay
  else
    note 'Skipped AUR packages: install linux-wallpaperengine-git with a reviewed, user-managed AUR workflow.'
    return 2
  fi
  run "$helper" -S --needed "${aur_packages[@]}"
}

install_source_actions() {
  ((${#source_actions[@]})) || return 0
  local action
  for action in "${source_actions[@]}"; do
    case "$action" in
      quickshell-ppa) install_quickshell_from_ppa ;;
      rust-toolchain) install_rust_toolchain ;;
      awww) install_awww_from_source ;;
      matugen) install_matugen_from_source ;;
      wallpaper-engine) install_wallpaper_engine_from_source ;;
      font) install_font ;;
    esac
  done
}

json_string() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '"%s"' "$value"
}

configure_shell() {
  local wm=sway qalc_path='' matugen_bin='' matugen_config=''
  local engine_path=linux-wallpaperengine wallpaper_enabled=false
  local desktop="${XDG_CURRENT_DESKTOP:-}"
  [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" || "${desktop,,}" == *hyprland* ]] && wm=hyprland
  "${selected[calculator]}" && qalc_path=qalc
  [[ "$distro" != arch ]] && engine_path="$bin_home/linux-wallpaperengine"
  if "${selected[wallpapers]}" || "${selected[wallpaper-engine]}"; then
    wallpaper_enabled=true
  fi

  if "${selected[colors]}"; then
    matugen_bin=matugen
    [[ "$distro" != arch ]] && matugen_bin="$HOME/.local/bin/matugen"
  fi
  matugen_config="$config_dir/matugen.toml"
  run install -m 600 "$SOURCE_ROOT/config/matugen/quickshell.template.json" "$data_dir/matugen.template.json"
  if [[ -e "$matugen_config" ]]; then
    note "Backing up $matugen_config to $matugen_config.bak"
    run install -m 600 "$matugen_config" "$matugen_config.bak"
  fi
  if "$dry_run"; then
    note "+ write matugen config $matugen_config (template: $data_dir/matugen.template.json; output: $config_dir/colors.json)"
  else
    cat >"$matugen_config" <<EOF
[config]
mode = "color"

[templates.quickshell]
input_path = $(json_string "$data_dir/matugen.template.json")
output_path = $(json_string "$config_dir/colors.json")
EOF
    chmod 600 "$matugen_config"
  fi

  generated_config="$config_dir/config.json"
  if [[ -e "$generated_config" ]]; then
    config_backup="$generated_config.bak"
    note "Backing up $generated_config to $config_backup"
    run install -m 600 "$generated_config" "$config_backup"
  fi
  note "Generating dependency-based config: $generated_config"
  if "$dry_run"; then
    note "+ write config: wm=$wm calculator=${selected[calculator]} clipboard=${selected[clipboard]} wallpapers=$wallpaper_enabled colors=${selected[colors]} wallpaper-engine=${selected[wallpaper-engine]}"
    return
  fi
  cat >"$generated_config" <<EOF
{
  "system": {
    "wm": "$wm",
    "matugenConfigPath": $(json_string "$matugen_config"),
    "matugenBin": $(json_string "$matugen_bin"),
    "primaryOutput": ""
  },
  "theme": { "darkTheme": true },
  "panel": { "enabled": true },
  "calendar": { "weekStart": "monday" },
  "launcher": {
    "enabled": true,
    "qalcPath": $(json_string "$qalc_path")
  },
  "clipboard": { "enabled": ${selected[clipboard]} },
  "wallpaper": {
    "enabled": $wallpaper_enabled,
    "engineEnabled": ${selected[wallpaper-engine]},
    "enginePath": $(json_string "$engine_path"),
    "workshopPath": "",
    "fps": 25,
    "fill": true,
    "matureContent": false,
    "volume": 50
  }
}
EOF
  chmod 600 "$generated_config"
}

install_shell() {
  readonly data_dir="$data_home/minima-shell"
  readonly config_dir="$config_home/minima"
  readonly launcher="$bin_home/minima-shell"
  readonly stage_dir="$data_home/.minima-shell-install.$$"

  temporary_dirs+=("$stage_dir")

  note "Installing Minima shell data to $data_dir"
  run install -d "$data_home" "$config_dir" "$bin_home"
  run mkdir -p "$stage_dir"
  run cp -a "$SOURCE_ROOT/shell/." "$stage_dir/"

  if [[ -e "$data_dir" ]]; then
    note "Replacing previously installed shell data at $data_dir"
    run rm -rf "$data_dir"
  fi
  run mv "$stage_dir" "$data_dir"

  if [[ ! -e "$config_dir/colors.json" ]]; then
    note "Seeding $config_dir/colors.json"
    run install -m 600 "$SOURCE_ROOT/colors.json" "$config_dir/colors.json"
  else
    note "Keeping existing $config_dir/colors.json"
  fi

  if "$dry_run"; then
    note "+ write launcher $launcher"
  else
    umask 077
    cat >"$launcher" <<EOF
#!/usr/bin/env sh
export XDG_CONFIG_HOME="$config_home"
export MINIMA_CONFIG="\${MINIMA_CONFIG:-$config_dir/config.json}"
exec qs -p "$data_dir/shell.qml" "\$@"
EOF
    chmod 700 "$launcher"
  fi
}

install_selected() {
  prepare_actions
  review_actions

  if ((${#native_packages[@]} + ${#aur_packages[@]} + ${#source_actions[@]})); then
    confirm 'Install the listed dependencies?' || fail 'dependency installation cancelled'
  fi

  bootstrap_source_tree
  if ! "$dry_run"; then
    source_tree_ready || fail 'run this script from a complete Minima source or release archive'
  fi
  install_native_packages
  if ((${#aur_packages[@]} + ${#source_actions[@]})); then
    confirm 'Proceed with third-party actions?' || {
      note 'Third-party actions skipped; installing the Minima shell with any native packages already selected.'
      local action
      for action in "${source_actions[@]}"; do
        case "$action" in
          awww) selected[wallpapers]=false ;;
          matugen) selected[colors]=false ;;
          wallpaper-engine|font) selected["$action"]=false ;;
        esac
      done
      aur_packages=()
      source_actions=()
      selected[wallpaper-engine]=false
    }
  fi
  if install_aur_packages; then
    :
  else
    local aur_status=$?
    if ((aur_status == 2)); then
      selected[wallpaper-engine]=false
    else
      return "$aur_status"
    fi
  fi
  install_source_actions
  if ! "$dry_run"; then
    command -v qs >/dev/null 2>&1 || fail 'QuickShell (qs) is required; Minima was not installed. See https://quickshell.org/docs/v0.3.2/guide/install-setup/'
  fi
  install_shell
  configure_shell

  if "$menu_active" && ! "$dry_run"; then
    menu_header 'Installation Complete'
  fi
  if "$dry_run"; then
    note "Dry run complete. Planned launcher: $launcher"
  else
    note "Installed launcher: $launcher"
  fi
  if [[ -n "$config_backup" ]]; then
    note "Previous config backed up to $config_backup."
  fi
  note
  note 'Start Minima:'
  note "  \"$launcher\""
  note
  note "Add $bin_home to PATH by putting this line in your ~/.bashrc or ~/.zshrc:"
  note "  export PATH=\"$bin_home:\$PATH\""
  note
  note 'Open a new terminal, then launch with:'
  note '  minima-shell'
  note
  note 'Start automatically with your compositor:'
  note
  note '  Hyprland (~/.config/hypr/hyprland.lua):'
  note '    hl.on("hyprland.start", function()'
  note "      hl.exec_cmd($(json_string "env PATH=\"$bin_home:\$HOME/.local/bin:\$PATH\" \"$launcher\""))"
  "${selected[clipboard]}" && note '      hl.exec_cmd("wl-paste --watch cliphist store")'
  "${selected[wallpapers]}" && note "      hl.exec_cmd($(json_string 'env PATH="$HOME/.local/bin:$PATH" awww-daemon'))"
  note '    end)'
  note
  note '  Sway / SwayFX / Scroll (your compositor config):'
  note "    exec \"$launcher\""
  "${selected[clipboard]}" && note '    exec wl-paste --watch cliphist store'
  "${selected[wallpapers]}" && note '    exec awww-daemon'
  note
  note 'Settings:'
  note "  $config_dir/config.json"
  note
  note 'Full guide:'
  note '  https://github.com/Poellebob/minima-shell/blob/master/NONNIX.md'
}

menu_header() {
  local title="$1"
  local cyan='' bold='' reset=''
  if [[ -t 1 && "${TERM:-dumb}" != dumb ]]; then
    printf '\033[H\033[2J'
    if [[ ! -v NO_COLOR ]]; then
      cyan=$'\033[36m'
      bold=$'\033[1m'
      reset=$'\033[0m'
    fi
  fi
  printf '%s%s' "$bold" "$cyan"
  note '  m i n i m a'
  note '  ------------------------------------------------------------'
  printf '  Non-Nix Shell Installer%s\n' "$reset"
  note
  printf '  %s%s%s\n' "$bold" "$title" "$reset"
  note
  if "$dry_run"; then
    note '  DRY RUN: No changes will be made.'
    note
  fi
}

menu_pause() {
  local answer
  note
  read -r -p 'Press Enter to continue...' answer || true
}

features_menu() {
  local choice feature
  while true; do
    menu_header 'Optional Dependencies'
    note '  Toggle features to install.'
    note
    note "  1. $(feature_name calculator) [$(feature_state calculator)]"
    note "  2. $(feature_name clipboard) [$(feature_state clipboard)]"
    note "  3. $(feature_name wallpapers) [$(feature_state wallpapers)]"
    note "  4. $(feature_name colors) [$(feature_state colors)]"
    note "  5. $(feature_name wallpaper-engine) [$(feature_state wallpaper-engine)]"
    note "  6. $(feature_name font) [$(feature_state font)]"
    note
    warn 'Skipping the font can break UI icons and layout. Only skip it if JetBrainsMono Nerd Font is already installed.'
    note
    note '  7. Select all'
    note '  8. Clear all (keep required runtime)'
    note '  0. Back'
    note
    read -r -p 'Select option [0]: ' choice || return 0
    case "$choice" in
      1) toggle_feature calculator ;;
      2) toggle_feature clipboard ;;
      3) toggle_feature wallpapers ;;
      4) toggle_feature colors ;;
      5) toggle_feature wallpaper-engine ;;
      6) toggle_feature font ;;
      7|8)
        for feature in "${!selected[@]}"; do
          if [[ "$choice" == 7 ]]; then
            selected["$feature"]=true
          else
            selected["$feature"]=false
          fi
        done
        ;;
      0|"") return ;;
      *) note 'Enter a menu number.'; menu_pause ;;
    esac
  done
}

paths_menu() {
  local choice path
  while true; do
    menu_header 'Installation Paths'
    note "  1. Data home:   $data_home"
    note "  2. Config home: $config_home"
    note "  3. Bin home:    $bin_home"
    note
    note '  4. Reset to XDG defaults'
    note '  0. Back'
    note
    read -r -p 'Select option [0]: ' choice || return 0
    case "$choice" in
      1|2|3)
        read -r -p 'Absolute path (Enter to keep current): ' path || return 0
        [[ -n "$path" ]] || continue
        if [[ "$path" != /* ]]; then
          note 'Use an absolute path, starting with /.'
          menu_pause
          continue
        fi
        case "$choice" in
          1) data_home="$path" ;;
          2) config_home="$path" ;;
          3) bin_home="$path" ;;
        esac
        ;;
      4)
        data_home="$DEFAULT_DATA_HOME"
        config_home="$DEFAULT_CONFIG_HOME"
        bin_home="$DEFAULT_BIN_HOME"
        ;;
      0|"") return ;;
      *) note 'Enter a menu number.'; menu_pause ;;
    esac
  done
}

show_menu_screen() {
  local feature count=0
  for feature in "${!selected[@]}"; do
    if "${selected[$feature]}"; then
      count=$((count + 1))
    fi
  done
  menu_header 'Configuration'
  note '  Installs QuickShell and its Qt runtime. Your window-manager config is not changed.'
  note
  note "  1. Package manager:       ${distro:-not selected}"
  note "  2. Optional dependencies: $count selected"
  note '  3. Installation paths'
  note
  note '  4. Review and install'
  note '  5. Check installed dependencies'
  note '  0. Exit'
  note
}

interactive_menu() {
  local choice answer
  menu_active=true
  while true; do
    show_menu_screen
    read -r -p 'Select option [0]: ' choice || return 0
    case "$choice" in
      1) choose_distro ;;
      2) features_menu ;;
      3) paths_menu ;;
      4)
        if [[ -z "$distro" ]]; then
          note 'Select a package-manager family first.'
          menu_pause
          continue
        fi
        menu_header 'Review Installation'
        note "  Shell data: $data_home/minima-shell"
        note "  Config:     $config_home/minima (config.json backed up, then replaced)"
        note "  Launcher:   $bin_home/minima-shell"
        note '  Shell data is replaced; existing palette colors are kept.'
        prepare_actions
        review_actions
        note
        read -r -p 'Proceed with this plan? [y/N] ' answer || return 0
        case "$answer" in
          y|Y|yes|YES)
            menu_header 'Installation Output'
            install_selected
            return
            ;;
        esac
        ;;
      5)
        menu_header 'Installed Dependencies'
        check_dependencies
        menu_pause
        ;;
      0|"") return ;;
      *) note 'Enter a menu number.'; menu_pause ;;
    esac
  done
}

while (($#)); do
  case "$1" in
    --dry-run) dry_run=true ;;
    --check) check_only=true ;;
    --no-menu) show_menu=false ;;
    --yes) assume_yes=true ;;
    --distro)
      (($# >= 2)) || fail "$1 requires arch, fedora, or debian"
      distro="$2"
      case "$distro" in arch|fedora|debian) ;; *) fail "unsupported distro: $distro" ;; esac
      shift
      ;;
    --with)
      (($# >= 2)) || fail "$1 requires a feature name"
      set_feature "$2"
      show_menu=false
      shift
      ;;
    --data-home|--config-home|--bin-home)
      (($# >= 2)) || fail "$1 requires a path"
      case "$1" in
        --data-home) data_home="$2" ;;
        --config-home) config_home="$2" ;;
        --bin-home) bin_home="$2" ;;
      esac
      shift
      ;;
    -h|--help) usage; exit 0 ;;
    *) fail "unknown option: $1" ;;
  esac
  shift
done

detect_distro
if "$check_only"; then
  check_dependencies
  exit 0
fi

if "$show_menu" && [[ -t 0 ]]; then
  interactive_menu
  exit 0
fi

[[ -n "$distro" ]] || fail 'could not detect a supported distribution; use --distro arch, fedora, or debian'
install_selected
