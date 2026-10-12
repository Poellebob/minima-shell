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

The downloaded installer retrieves Minima into a temporary directory, shows the
optional dependency menu, installs the shell, then removes that temporary
source tree. It uses a shallow Git clone when available and otherwise downloads
the GitHub source archive with `curl` and `tar`. To inspect the installer before
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
| `${XDG_DATA_HOME:-~/.local/share}/minima-shell` | Minima's QML shell |
| `${XDG_CONFIG_HOME:-~/.config}/minima/config.json` | Minima settings, seeded only if missing |
| `${XDG_CONFIG_HOME:-~/.config}/minima/colors.json` | Default palette, seeded only if missing |
| `~/.local/bin/minima-shell` | Launcher |

`--dry-run` prints all file operations. `--check` only reports available
runtime and optional commands. Use `--data-home`, `--config-home`, or
`--bin-home` to use non-default locations.

## Optional Dependency Menu

When run from a terminal, the installer shows a menu for selecting only the
optional features you want:

```text
1. Calculator (qalc)
2. Clipboard history (cliphist, wl-clipboard)
3. Static wallpapers (awww)
4. Wallpaper palette generation (matugen)
5. Wallpaper Engine (linux-wallpaperengine)
6. JetBrainsMono Nerd Font
```

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
  font cache.

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

Wallpaper Engine is disabled in the seeded configuration. To enable it, set
`wallpaper.engineEnabled` to `true`, set `wallpaper.workshopPath` to your local
Steam Workshop `431960` directory, and keep `wallpaper.enginePath` pointed at
the executable. Minima will not install Steam or download Workshop content.
The current shell stops existing `linux-wallpaperengine` processes before it
starts one, so do not enable this feature alongside independently managed
Wallpaper Engine instances.

## Configuration

Set `system.wm` in `config.json` to `hyprland`, `sway`, `swayfx`, or `scroll`
to match your existing compositor. The default is `sway`.

To enable calculator results, set `launcher.qalcPath` to the path of `qalc`.
It is empty by default so a missing optional calculator is never started.

When the installer creates a new `config.json`, selecting the calculator sets
`launcher.qalcPath` to `qalc`. Selecting Wallpaper Engine enables it and sets
its executable path. Existing configuration is never edited automatically.

Keep `MINIMA_CONFIG` set to use a different configuration file. The launcher
sets it to the installed `config.json` only when it is otherwise unset.

Changing the wallpaper can invoke `matugen` when both `system.matugenBin` and
`system.matugenConfigPath` are configured. The current shell also runs
`hyprctl reload` after a successful palette generation; leave matugen unset on
non-Hyprland sessions until that behavior is made compositor-aware.

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
