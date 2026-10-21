# Non-Nix User Guide

Run Minima without Nix in an existing **Hyprland, Sway, SwayFX, or Scroll**
session. The installer sets up the shell, not your window manager or global theme.
Non-Nix support is **experimental**.

## Distro Compatibility

| Distribution | QuickShell availability |
| --- | --- |
| Arch | Native `quickshell` package |
| Fedora | Native package, with an optional `errornointernet/quickshell` COPR fallback |
| Debian | Requires a repository providing `quickshell`, such as testing or unstable; the installer does not add these repositories |
| Ubuntu / Ubuntu-based | Offers `ppa:avengemedia/danklinux` if `qs` is missing; your Ubuntu release must be available in the PPA |

Package availability varies by release. Third-party repositories require separate
confirmation and stay enabled for updates. Debian never receives an Ubuntu PPA.

## Install

Run as your normal user, not root; the installer uses `sudo` for system packages:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/Poellebob/minima-shell/master/nonnix/install.sh)
```

Choose your **Window manager** and optional features, then **Review and install**.
QuickShell and its runtime are always installed. Calculator, clipboard history,
palette generation, and JetBrainsMono Nerd Font are selected by default;
wallpapers are optional. Keep the font selected unless you already have it.

Review package, repository, and download prompts before accepting. Some optional
features build from source and may install or update Rust through rustup.
Wallpaper Engine on Arch requires `yay` or `paru`; Steam and Workshop content
must already be installed separately.

## Start Minima

From your Wayland session, run:

```sh
~/.local/bin/minima-shell
```

For automatic startup, add the matching example below. Omit the clipboard or
wallpaper command if you did not select that feature.

### Hyprland

Add to `~/.config/hypr/hyprland.lua`:

```lua
hl.on("hyprland.start", function()
  hl.exec_cmd('env PATH="$HOME/.local/bin:$PATH" "$HOME/.local/bin/minima-shell"')
  hl.exec_cmd("wl-paste --watch cliphist store")
  hl.exec_cmd('env PATH="$HOME/.local/bin:$PATH" awww-daemon')
end)
```

### Sway, SwayFX, or Scroll

Add to your compositor config, usually `~/.config/sway/config`:

```sway
exec ~/.local/bin/minima-shell
exec wl-paste --watch cliphist store
exec awww-daemon
```

Ensure `~/.local/bin` is in your compositor's `PATH`. Use your chosen launcher
path instead if you changed it during installation.

## Usage

Settings live in `~/.config/minima/` (or `$XDG_CONFIG_HOME/minima/`):

- `config.json`: shell settings and features. Set `system.wm` to `hyprland` or
  `sway` (also used by SwayFX and Scroll).
- `colors.json`: current palette; palette generation changes Minima, not global themes.

Control a running Minima shell from a terminal or compositor keybinding:

```sh
minima-shell ipc call <target> <function> [args...]
```

| Target | Function | Arguments |
| --- | --- | --- |
| `power` | `open` | None |
| `minimaLock` | `open` | None |
| `systray` | `open` | `index` (integer) |
| `notifications` | `open` | None |
| `logout` | `open` | None |
| `launcher` | `open` | None |
| `clipboard` | `open` | None |

For example:

```sh
minima-shell ipc call launcher open
minima-shell ipc call minimaLock open
minima-shell ipc call systray open 2
```

If `~/.local/bin` is not in your `PATH`, use
`~/.local/bin/minima-shell` instead of `minima-shell`.

For **Super+D**, add one binding to your compositor config, replacing any existing
binding for that shortcut. Hyprland:

```lua
hl.bind("SUPER + D", hl.dsp.exec_cmd("~/.local/bin/minima-shell ipc call launcher open"))
```

Sway, SwayFX, or Scroll:

```sway
bindsym Mod4+d exec ~/.local/bin/minima-shell ipc call launcher open
```

For static wallpapers, put images in `~/Wallpapers`. For Wallpaper Engine, set
`wallpaper.workshopPath` in `config.json` to your Steam Workshop `431960`
directory with a trailing `/`. Minima stops other `linux-wallpaperengine`
processes, so do not run a separate instance alongside it.

## Updating

Rerun the installer to update or change features. **Back up your custom settings
first:** it replaces `config.json` and `matugen.toml`, keeping only the previous
version of each as `.bak`. `colors.json` is preserved.

## Troubleshooting

- **Shell will not start / missing QML modules:** run the launcher in a terminal
  to see the error. Check your distro's QuickShell availability above and see
  the [QuickShell installation guide](https://quickshell.org/docs/v0.3.2/guide/install-setup/).
  For missing `qs`, rerun the installer and accept the required dependency prompts.
- **Missing icons:** install JetBrainsMono Nerd Font.
- **Empty clipboard history:** make sure `wl-paste --watch cliphist store` is running.
- **Rust `lock file version 4` error:** rerun the current installer, which uses
  stable Rust instead of an older distro toolchain. Back up settings first.
- **Network, audio, Bluetooth, or power controls fail:** these need running host
  services: NetworkManager (`nmcli`), PipeWire with a session manager such as
  WirePlumber, BlueZ, and UPower / power-profiles-daemon respectively. The
  installer does not enable or replace these services.

From a source checkout, `./nonnix/install.sh --check` checks available commands
(not running services); `./nonnix/install.sh --help` lists installer options.
