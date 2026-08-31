# minima-shell

A NixOS/home-manager flake providing a Wayland-focused desktop environment with [Hyprland](https://hyprland.org/), [Sway](https://swaywm.org/), [SwayFX](https://github.com/Ericmorgenta/swayfx), and [Scroll](https://github.com/dawsers/scroll/) support.

> [!WARNING]
> This project is not done and is still **pre-alpha**; it will contain bugs.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Flake Outputs](#flake-outputs)
- [Features](#features)
- [Keybinds](#keybinds)
- [Related Documentation](#related-documentation)

---

## Prerequisites

Minima is not a standalone program — it is a Home Manager module. **Home Manager is required**, regardless of how you use minima:

- On a non-NixOS distro, minima runs as a standalone Home Manager configuration on top of an already-installed window manager.
- On NixOS, minima is a NixOS module that installs the window manager
and passes system-level options down to Home Manager, which actually manages
all of your config files, the QuickShell panel, styling, and shell setup.

You also need a window manager — **Hyprland** (the default), **Sway**,
**SwayFX**, or **Scroll**. Select it with `minima.hyprland.enable`
(default `true`), `minima.sway.enable` (`minima.sway.fx = true` for
SwayFX), or `minima.scroll.enable`. Enabling sway or scroll automatically
disables Hyprland unless you set `minima.hyprland.enable` explicitly; at
most one window manager may be enabled at a time.

---

## Quick Start

### Home Manager (standalone, any distro)

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.minima = {
    url = "github:Poellebob/minima-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, minima, ... }: {
    homeConfigurations."your-username" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        minima.homeModules.default
        {
          home.stateVersion = "25.11";
          minima = {
            enable = true;
            hyprland.enable = true;  # default; or sway.enable / scroll.enable
            shell.enable = true;
            theming.enable = true;
            minimaConfig = {
              darkTheme = true;
              wallpaper.engineEnabled = true;
              panel.alwaysVisible = true;
            };
            vim.enable = true;
          };
        }
      ];
    };
  }
}
```

> This expects the selected window manager to already be installed on your system (Hyprland works out of the box as the default). The NixOS module installs the window manager for you based on which one is enabled.

### NixOS

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.minima = {
    url = "github:Poellebob/minima-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, minima, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        minima.nixosModules.minima
        {
          # System-level: installs & wraps the window manager, passes options
          # down to home-manager via sharedModules.
          minima = {
            enable = true;
            sway.enable = true;  # or hyprland.enable (default) / scroll.enable
            enableNvidia = false;
          };

          home-manager.users."your-username" = {
            imports = [
              minima.homeModules.default
            ];
            home.stateVersion = "25.11";
            minima = {
              enable = true;
              shell.enable = true;
              theming.enable = true;
              minimaConfig = {
                darkTheme = true;
                wallpaper.engineEnabled = true;
                panel.alwaysVisible = true;
              };
              vim.enable = true;
            };
          };
        }
      ];
    };
  };
}
```

---

## Flake Outputs

```nix
outputs = { self, ... }: {
  homeModules.minima = ...;   # Home Manager module
  homeModules.default  = ...; # alias for homeModules.minima
  nixosModules.minima = ...;  # NixOS module
  nixosModules.default = ...; # alias for nixosModules.minima
}
```

All configuration options are documented in [OPTIONS.md](./OPTIONS.md).

---

## Features

- **Hyprland / Sway / SwayFX / Scroll** — pick your window manager with `minima.hyprland.enable`, `minima.sway.enable` (+ `minima.sway.fx`), or `minima.scroll.enable`
- **QuickShell panel & launcher** — animated bar, app launcher with qalc, clipboard manager, wallpaper engine support
- **Material you theming** — matugen-rendered colors using a seed color, applied to the panel, launcher, and Sway
- **KDE-style styling** — Breeze cursor/GTK/Qt theming, Papirus icons, `kdeglobals`
- **Shell setup** — zsh, starship, eza, fzf, zoxide, bat, ripgrep, lazygit
- **Neovim via NixVim** — batteries-included editor with LSP, completion, formatting, and linting
- **Extra packages** — add anything with `minima.extraPackages`
- **NVIDIA support** — flip on `minima.enableNvidia` for proprietary driver handling
- **Desktop integration** — XDG portals, desktop menus, Dolphin-adjacent KDE packages

---

## Keybinds

> **Note:** Scroll has a few unique keybinds not available in Sway, and vice versa.

### General

| Keybind | Action (Sway) | Action (Scroll) |
|--------|---------------|---------------|
| `$mod + Return` | Open terminal | Open terminal |
| `$mod + q` | Kill focused window | Kill focused window |
| `$mod + e` | Open file manager | Open file manager |
| `$mod + b` | Open browser | Open browser |
| `$mod + Space` | Toggle floating | Toggle floating |
| `$mod + f` | Toggle fullscreen | Toggle fullscreen |
| `$mod + Shift + s` | Toggle sticky | Toggle sticky |
| `$mod + Alt + Delete` | Lock screen (swaylock) | Lock screen (swaylock) |
| `$mod + v` | Open clipboard manager | Open clipboard manager |
| `$mod + d` | Open app launcher | Open app launcher |
| `$mod + Shift + c` | Reload config | Reload config |
| `$mod + Alt + l` | Tabbed layout | Set window height to 100% |
| `$mod + Alt + h` | Stacking layout | Set window height to 50% |
| `$mod + Alt + j` | Split vertical | Move window into column on left |
| `$mod + Alt + k` | Split horizontal | Move window into column on right |
| `$mod + a` | Split toggle | Direction mode |
| `$mod + Shift + a` | Focus parent | - |
| `$mod + Ctrl + a` | Focus child | - |
| `$mod + Escape` | Default layout | - |
| `$mod + Tab` | - | Workspace overview |
| `$mod + Shift + -` | - | Move to scratchpad |
| `$mod + -` | - | Show scratchpad |
| `XF86PowerOff` | Open logout menu | Open logout menu |

### Workspaces

| Keybind | Action |
|--------|--------|
| `$mod + 1-9, 0` | Switch to workspace 1-10 |
| `$mod + Shift + 1-0` | Move window to workspace |
| `$mod + Ctrl + Right` | Next workspace |
| `$mod + Ctrl + Left` | Previous workspace |

### Focus Movement (vim-style)

| Keybind | Action |
|--------|--------|
| `$mod + H` | Focus left |
| `$mod + L` | Focus right |
| `$mod + K` | Focus up |
| `$mod + J` | Focus down |

### Move Windows

| Keybind | Action |
|--------|--------|
| `$mod + Ctrl + H` | Move window left |
| `$mod + Ctrl + L` | Move window right |
| `$mod + Ctrl + K` | Move window up |
| `$mod + Ctrl + J` | Move window down |

### Resize Windows

| Keybind | Action |
|--------|--------|
| `$mod + Shift + H` | Shrink width 100px |
| `$mod + Shift + L` | Grow width 100px |
| `$mod + Shift + K` | Shrink height 100px |
| `$mod + Shift + J` | Grow height 100px |

### Screenshots

| Keybind | Action |
|--------|--------|
| `Shift + Print` | Screenshot fullscreen → clipboard |
| `$mod + Print` | Screenshot selection → edit in swappy |
| `$mod + Shift + Print` | Screenshot fullscreen → edit in swappy |

### Multimedia

| Keybind | Action |
|--------|--------|
| `XF86AudioRaiseVolume` | Volume up 5% |
| `XF86AudioLowerVolume` | Volume down 5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Brightness up 10% |
| `XF86MonBrightnessDown` | Brightness down 10% |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `XF86AudioPlay/Pause` | Play/Pause |

---

## Related Documentation

- [OPTIONS.md](./OPTIONS.md) - All configuration options and how to use them
