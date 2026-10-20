# Non-Nix Installation

This is an early, shell-only installation path for a Wayland session that you
already manage. It installs the QuickShell application and Minima's own user
configuration. It does not install, generate, or edit configuration for
Hyprland, Sway, SwayFX, Scroll, a terminal, an editor, or global theming.

## Install

Install a compatible QuickShell build that provides the modules used by the
shell, then run:

```sh
bash -c <(curl -fsSL https://raw.githubusercontent.com/Poellebob/minima-shell/master/nonnix/install.sh)
```

<details>
<summary>Install the <code>devel/master</code> branch</summary>

```sh
MINIMA_REF=devel/master bash -c <(curl -fsSL https://raw.githubusercontent.com/Poellebob/minima-shell/master/nonnix/install.sh)
```

</details>

`master` is the default when `MINIMA_REF` is unset. The development command
uses the stable installer bootstrap and retrieves the `devel/master` source
tree.

The downloaded installer opens the configuration menu first. After you review
and confirm installation, it retrieves Minima into a temporary directory,
installs the shell, then removes that temporary source tree. Exiting the menu
does not download or install anything. It uses a shallow Git clone when
available and otherwise downloads the GitHub source archive with `curl` and
`tar`. To inspect the installer before
running anything, download it instead:

```sh
curl -fsSLO https://raw.githubusercontent.com/Poellebob/minima-shell/master/nonnix/install.sh
less install.sh
```

Running from a complete source checkout or release archive also works:

```sh
./nonnix/install.sh
```

The installer is user-local and does not require root. It installs:

| Path | Contents |
| --- | --- |
| `${XDG_DATA_HOME:-~/.local/share}/minima-shell/` | Contents of `shell/`, with `shell.qml` directly here |
| `${XDG_CONFIG_HOME:-~/.config}/minima/config.json` | Settings generated from selected dependencies, created if missing |
| `${XDG_CONFIG_HOME:-~/.config}/minima/colors.json` | Default palette, seeded only if missing |
| `~/.local/bin/minima-shell` | Launcher |

`--dry-run` prints all file operations. `--check` only reports available
runtime and optional commands. Use `--data-home`, `--config-home`, or
`--bin-home` to use non-default locations.

The launcher starts `qs -p ~/.local/share/minima-shell/shell.qml` using the
chosen installation paths. It defaults `MINIMA_CONFIG` to the installed
configuration, preserving a nonempty override from the environment. It also
sets `XDG_CONFIG_HOME` so the palette follows the chosen config home.

## Terminal Menu

When run from a terminal, the installer shows a full-screen, numbered menu:

```text
1. Package manager:       <detected family>
2. Optional dependencies: 0 selected
3. Installation paths

4. Review and install
5. Check installed dependencies
0. Exit
```

Enter a number and press Enter to navigate. Submenus return with `0` or an
empty selection. You can override the detected package-manager family and edit
installation paths before reviewing the complete plan. The review screen
requires an explicit `y` to proceed. Dry-run is only enabled with the
`--dry-run` flag, which opens
the same menu in dry-run mode; add `--no-menu` to print a plan directly.
Color is disabled when `NO_COLOR` is set, and dumb terminals use plain output.
After a successful install, the menu is cleared and the installer exits with
next steps left on screen. These include Hyprland and Sway startup examples,
plus clipboard history and wallpaper daemon commands when selected. It does
not wait for another Enter or reopen the menu.

The optional dependency submenu lets you toggle individual features, select
all, or clear all for a shell-only installation. All features start deselected:

```text
1. Calculator (qalc)
2. Clipboard history (cliphist, wl-clipboard)
3. Static wallpapers (awww)
4. Wallpaper palette generation (matugen)
5. Wallpaper Engine (linux-wallpaperengine)
6. JetBrainsMono Nerd Font
```

Skipping the font can break Minima's UI icons and layout. The option is
provided so you can skip installation if JetBrainsMono Nerd Font is already
installed; otherwise, select it.

The menu supports Arch Linux, Fedora, and Debian/Ubuntu package families. It
shows the exact package transaction before asking for confirmation. Only the
selected native packages use `sudo`; installing the Minima shell itself stays
user-local. It never installs or changes WM configuration.

For automation, use `--distro arch|fedora|debian --with FEATURE --no-menu`.
Repeat `--with` for multiple features. Add `--yes` only when you have already
reviewed the requested package and third-party actions.

## Third-Party Actions

Not every optional tool is packaged by every supported distribution. The menu
requires a second confirmation before these actions:

- On Arch, Wallpaper Engine uses `linux-wallpaperengine-git` through an
  already-installed `yay` or `paru`. The installer never installs an AUR helper.
- On Fedora and Debian/Ubuntu, `awww` is built from its upstream Codeberg source
  with Cargo into `~/.local/bin`, and `matugen` is installed from crates.io in
  the same location. Their Rust toolchains are selected as native build
  dependencies.
- On Fedora and Debian/Ubuntu, Wallpaper Engine is cloned from upstream and
  compiled with CMake after installing its documented development dependencies.
- On Fedora and Debian/Ubuntu, the font selection downloads the latest
  JetBrainsMono Nerd Font archive to the user font directory and refreshes the
  font cache. Its download, extraction, and font-cache prerequisites are
  included in the native package selection.

The installer does not add COPR, PPA, backports, RPM Fusion, or other
repositories. It also never installs Steam or downloads Wallpaper Engine
Workshop content. Package availability still depends on the selected distro
release and its enabled native repositories.

Add your own startup command for `minima-shell` to the Wayland session you
already use. The installer deliberately does not do this because startup syntax
and environment propagation are owned by the compositor configuration.

## Required Runtime

- A compatible `qs` QuickShell runtime with Wayland, I3, Hyprland, Widgets,
  DBusMenu, Notifications, PAM, PipeWire, MPRIS, UPower, Bluetooth, and
  Networking QML modules.
- A running Wayland compositor. Minima's workspace integration supports
  Hyprland and the Sway/I3 IPC family.
- A session D-Bus environment and the host services needed for the features
  you intend to use.
- A Nerd Font compatible with `JetBrainsMono Nerd Font` for UI glyphs.

QuickShell itself remains a prerequisite because version and module support
vary across distributions. Install a compatible build through the native
mechanism you trust before running Minima.

## Optional Dependencies

| Feature | Commands or services |
| --- | --- |
| Calculator | `qalc` |
| Clipboard history | `cliphist`, `wl-copy`, `wl-paste` |
| Static wallpapers | `awww`, `awww-daemon` |
| Palette generation | `matugen` plus a configured template |
| Wallpaper Engine | `linux-wallpaperengine` and accessible Steam Workshop content |
| Network controls | NetworkManager and `nmcli` |
| Audio controls | PipeWire with a session manager such as WirePlumber |
| Bluetooth controls | BlueZ |
| Battery and power profiles | UPower and power-profiles-daemon |

Selecting Wallpaper Engine enables it in the generated configuration and sets
its executable path. Set `wallpaper.workshopPath` to your local Steam Workshop
`431960` directory, including a trailing `/`. If configuring it manually, also
set `wallpaper.engineEnabled` to `true` and `wallpaper.enginePath` to the
executable. Minima will not install Steam or download Workshop content.
The current shell stops existing `linux-wallpaperengine` processes before it
starts one, so do not enable this feature alongside independently managed
Wallpaper Engine instances.

## Configuration

Set `system.wm` in `config.json` to `hyprland`, `sway`, `swayfx`, or `scroll`
to match your existing compositor. The installer detects an active Hyprland
session from `HYPRLAND_INSTANCE_SIGNATURE` or `XDG_CURRENT_DESKTOP` and
otherwise defaults to `sway`.

To enable calculator results, set `launcher.qalcPath` to the path of `qalc`.
It is empty by default so a missing optional calculator is never started.

The installer generates settings from the dependencies actually installed:

| Selection | Generated Settings |
| --- | --- |
| Calculator | Sets `launcher.qalcPath` to `qalc`, otherwise empty |
| Clipboard | Sets `clipboard.enabled` according to selection |
| Static wallpapers or Wallpaper Engine | Enables `wallpaper.enabled`, otherwise false |
| Wallpaper Engine | Enables `wallpaper.engineEnabled` and sets its executable path |
| Palette generation | Sets matugen executable and configuration paths; installs a shell-only palette template |
| Font | Installs the UI's hardcoded JetBrainsMono Nerd Font; no font setting is needed |

Declined third-party actions are not enabled in the generated config.
Existing `config.json` is never overwritten: a selection-based
`config.json.new` is written alongside it for you to review and merge. Existing
`colors.json` and `matugen.toml` are also preserved.

The matugen configuration writes to Minima's `colors.json`, without adding
global theme templates. Successful generation reloads Hyprland only in a
Hyprland session; Sway sessions do not run `hyprctl`.

To run a different config manually, override `MINIMA_CONFIG`:

```sh
MINIMA_CONFIG=/path/to/config.json ~/.local/bin/minima-shell
```

Or just edit `$HOME/.config/minima/config.json`

## Current Limitations

- QuickShell version compatibility has not yet been pinned or tested across
  distributions.
- Optional features need better graceful handling when their commands or host
  services are unavailable.
- The installer does not yet create optional user services for clipboard or
  wallpaper daemons.
- Wallpaper Engine process ownership is not yet isolated to Minima-launched
  instances.
- There is not yet an uninstall command or packaged release archive.
