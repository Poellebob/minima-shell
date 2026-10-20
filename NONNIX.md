# Non-Nix User Guide

Install and run Minima in your existing Wayland session without Nix. The
installer sets up the shell only; it does not change your window manager,
terminal, editor, or global theme.

## Before You Start

- Use Hyprland, Sway, SwayFX, or Scroll.
- Install a compatible [QuickShell](https://quickshell.org/) build providing
  `qs` and the Wayland, I3, Hyprland, Widgets, DBusMenu, Notifications, PAM,
  PipeWire, MPRIS, UPower, Bluetooth, and Networking modules.
- Run from your normal user account, not as root. Optional system packages
  are installed through `sudo`.

This installation path is experimental. QuickShell compatibility and package
availability can vary by distribution and release.

## Install

Run in a terminal:

```sh
bash -c <(curl -fsSL https://raw.githubusercontent.com/Poellebob/minima-shell/master/nonnix/install.sh)
```

To use the development branch instead:

```sh
MINIMA_REF=devel/master bash -c <(curl -fsSL https://raw.githubusercontent.com/Poellebob/minima-shell/master/nonnix/install.sh)
```

From an existing source checkout, run `./nonnix/install.sh`.

In the menu, check the detected package-manager family (Arch, Fedora, or
Debian/Ubuntu), choose optional dependencies, then select **Review and install**.
You can also change installation paths or check installed dependencies.

Calculator, clipboard history, palette generation, and JetBrainsMono Nerd Font
are selected by default. Static wallpapers and Wallpaper Engine are off by
default. Only skip the font if it is already installed; Minima needs it for
icons and layout.

Review the listed packages before confirming. AUR packages and upstream
builds/downloads require a separate confirmation:

- Arch Wallpaper Engine installation requires an existing `yay` or `paru`.
- Fedora and Debian/Ubuntu build `awww` and Wallpaper Engine from source,
  install `matugen` through Cargo, and download the font from Nerd Fonts.
- Building `awww` or `matugen` installs or updates stable Rust through
  [rustup](https://rustup.rs/). The installer uses this toolchain explicitly;
  it does not change your shell profile or default Rust toolchain. Distribution
  Rust packages can be too old, including those on Linux Mint / Ubuntu 24.04.

The installer does not add package repositories, install Steam, or download
Workshop content.

## Start Minima

From your Wayland session, run:

```sh
~/.local/bin/minima-shell
```

To start automatically, add the appropriate commands to your compositor
configuration. Include the clipboard and wallpaper commands only if you
selected those features.

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

```text
exec ~/.local/bin/minima-shell
exec wl-paste --watch cliphist store
exec awww-daemon
```

Ensure `~/.local/bin` is in your compositor's `PATH`. If you changed the
launcher directory during installation, use that path instead.

## Configure

Edit the files in `~/.config/minima/` (or `$XDG_CONFIG_HOME/minima/`):

| File | Purpose |
| --- | --- |
| `config.json` | Shell settings and enabled features |
| `colors.json` | Current palette |
| `matugen.toml` | Palette-generation template and output paths |

The installer detects Hyprland and otherwise defaults to Sway. Set `system.wm`
in `config.json` to `hyprland`, `sway`, `swayfx`, or `scroll` as needed.
Other feature settings are generated from your installation selections.

### Wallpapers

For static wallpapers, put images in `~/Wallpapers` and start `awww-daemon`
with your session.

For Wallpaper Engine, set `wallpaper.workshopPath` in `config.json` to your
Steam Workshop `431960` directory, including a trailing `/`. Selecting the
feature during installation sets `wallpaper.engineEnabled` and the executable
path for you. Do not run independently managed Wallpaper Engine instances
alongside Minima: it currently stops existing `linux-wallpaperengine` processes.

Palette generation uses Minima's own matugen template and updates `colors.json`,
not global application themes.

### Reinstalling

Rerun the installer to update the shell or change selected features.
Reinstalling replaces shell data, `config.json`, and `matugen.toml`. The two
config files are backed up to `config.json.bak` and `matugen.toml.bak`;
each backup keeps only the version from the most recent reinstall. Save any
customizations you want to keep before reinstalling. `colors.json` is preserved.

## Troubleshooting

From a source checkout, check available commands without installing anything:

```sh
./nonnix/install.sh --check
```

- If `qs` is missing or reports unavailable QML modules, install a compatible
  QuickShell build. The installer does not install QuickShell.
- If icons are missing, install JetBrainsMono Nerd Font.
- If an older installer fails with `lock file version 4` while installing
  matugen, rerun the current installer. It uses stable Rust rather than the
  distribution's older Cargo. Reinstalling backs up and replaces settings as
  described above.
- If clipboard history is empty, make sure `wl-paste --watch cliphist store`
  is running in your Wayland session.
- Network controls need NetworkManager and `nmcli`; audio needs PipeWire and a
  session manager such as WirePlumber; Bluetooth needs BlueZ; power features
  need UPower and power-profiles-daemon. These host services are not set up by
  the installer.

## Installer Options

Use `./nonnix/install.sh --help` for all options. To preview changes without
writing files:

```sh
./nonnix/install.sh --dry-run --no-menu
```

For unattended installation, use `--no-menu --yes` with
`--distro arch|fedora|debian` if detection needs overriding. Add features with
repeated `--with FEATURE` options; these add to the defaults, not replace them.
Use `--yes` only after reviewing package and third-party actions.

Custom locations are available through `--data-home`, `--config-home`, and
`--bin-home`. Shell data defaults to `~/.local/share/minima-shell/`.
To launch with a different settings file:

```sh
MINIMA_CONFIG=/path/to/config.json ~/.local/bin/minima-shell
```
