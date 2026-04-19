# minima-shell

A NixOS/home-manager flake providing a Wayland-focused desktop environment with [Hyprland](https://hypr.land/), [Sway](https://swaywm.org/), [SwayFX](https://github.com/Ericmorgenta/swayfx), and [Scroll](https://github.com/dawsers/scroll/) support.

**Warning:** This project is not done and is still **pre-alpha**; it will contain bugs.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Flake Usage](#flake-usage)
- [Keybinds](#keybinds)
- [Related Documentation](#related-documentation)

---

## Quick Start

### Basic NixOS Configuration

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
    homeConfigurations."your-username" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        minima.homeModules.minima
        {
          minima = {
            enable = true;
            wm = "hyprland";  # hyprland, sway, swayfx, or scroll
          };
          home-manager.users.<username> = {
            home.stateVersion = "25.11";
            imports = [ 
              minima.homeModules.default 
            ];
            minima = {
              enable = true;
              shell.enable = true;
              theming.enable = true;
              enableBranding = true;
              minimaConfig = {
                darkTheme = true;
                wallpaper.engineEnabled = true;
                panel.alwaysVisible = true;
              };

              vim = {
                enable = true;
              };
            };
          };
        };
      ];
    };
  };
}
```

### Flake Outputs

```nix
outputs = { self, ... }: {
  homeModules.minima = ...;   # Home Manager module
  nixosModules.minima = ...;  # NixOS module
}
```

---

## Keybinds

> **Note:** Scroll has a few unique keybinds not available in Sway, and vice versa.

### General

| Keybind | Action (Hyprland) | Action (Sway) | Action (Scroll) |
|--------|-------------------|---------------|-----------------|
| `$mod + Return` | Open terminal | Open terminal | Open terminal |
| `$mod + Q` | Kill focused window | - | - |
| `$mod + q` | - | Kill focused window | Kill focused window |
| `$mod + E` | Open file manager | - | - |
| `$mod + e` | - | Open file manager | Open file manager |
| `$mod + B` | Open browser | - | - |
| `$mod + b` | - | Open browser | Open browser |
| `$mod + Space` | Toggle floating | Toggle floating | Toggle floating |
| `$mod + F` | Toggle fullscreen | - | - |
| `$mod + f` | - | Toggle fullscreen | Toggle fullscreen |
| `$mod + Shift + s` | - | Toggle sticky | Toggle sticky |
| `$mod + Alt + Delete` | Lock screen | Lock screen (hyprlock) | Lock screen (hyprlock) |
| `$mod + C` | Copy window class to clipboard | - | - |
| `$mod + v` | Open clipboard manager | Open clipboard manager | Open clipboard manager |
| `$mod + d` | Open app launcher | Open app launcher | Open app launcher |
| `$mod + Shift + c` | - | Reload config | Reload config |
| `$mod + Alt + l` | - | Tabbed layout | Set window height to 100% |
| `$mod + Alt + h` | - | Stacking layout | Set window height to 50% |
| `$mod + Alt + j` | - | Split vertical | Move window into column on left |
| `$mod + Alt + k` | - | Split horizontal | Move window into column on right |
| `$mod + a` | - | Split toggle | Direction mode |
| `$mod + Shift + a` | - | Focus parent | - |
| `$mod + Ctrl + a` | - | Focus child | - |
| `$mod + Escape` | - | Default layout | - |
| `$mod + Tab` | - | - | Workspace overview |
| `$mod + Shift + -` | - | Move to scratchpad | Move to scratchpad |
| `$mod + -` | - | Show scratchpad | Show scratchpad |
| `XF86PowerOff` | Open logout menu | Open logout menu | Open logout menu |

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

### Mouse Bindings (Hyprland only)

| Keybind | Action |
|--------|--------|
| `$mod + Left Click` | Move window |
| `$mod + Right Click` | Resize window |

### Screenshots

| Keybind | Action |
|--------|--------|
| `Print` | Screenshot selection → clipboard |
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
- [NONNIX.md](./NONNIX.md) - Manual setup guide without Nix (Arch Linux packages, copy to home, shell profiles)
