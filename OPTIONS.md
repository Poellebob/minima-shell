# Configuration Options

This document details all configuration options available in minima.

---

## Table of Contents

- [Core Options](#core-options)
- [Hyprland](#hyprland)
- [Program Options](#program-options)
- [Display & Workspaces](#display--workspaces)
- [Desktop Integration](#desktop-integration)
- [TeX/LaTeX](#texlatex)
- [Panel & Launcher](#panel--launcher)
- [Vim/Editor Options](#vimeditor-options)

---

## Core Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.enable` | bool | `false` | Enable Minima shell |
| `minima.wm` | enum | `"sway"` | Window manager: `"sway"`, `"swayfx"`, `"scroll"`, `"hyprland"` |
| `minima.hyprland.layout` | enum | `"dwindle"` | Hyprland layout engine (see [Hyprland](#hyprland)) |
| `minima.enableNvidia` | bool | `false` | Enable NVIDIA GPU support |
| `minima.modifier` | string | `"Mod4"` | Window manager modifier key (Hyprland always uses `SUPER`/Mod4) |
| `minima.theming.enable` | bool | `true` | Enable Breeze/Papirus/Rose-Pine styling |
| `minima.shell.enable` | bool | `true` | Enable zsh, fzf, starship, etc. |
| `minima.extraPackages` | list | `[]` | Extra packages to install |

### Example

```nix
{
  minima = {
    enable = true;
    wm = "sway";
    enableNvidia = true;
    modifier = "Mod4";
    theming.enable = true;
    extraPackages = with pkgs; [ git curl ];
  };
}
```

---

## Hyprland

Minima generates a Hyprland Lua config (`hyprland.lua`, the `hl.*` API) equivalent
to the Sway config: same keybinds, autostart, monitors, special workspaces,
gaps (3/3), 2px borders, no rounding, blur and shadows (SwayFX parity), and a
`localectl` keyboard-layout sync on start/reload.

> [!NOTE]
> While Hyprland support is in active development it is **always enabled**:
> the config is generated per-user through home-manager's
> `wayland.windowManager.hyprland` module (`configType = "lua"`, minima's
> config pulled in via `extraConfig`), and Hyprland is installed regardless of
> `minima.wm` — system-wide via `programs.hyprland` on NixOS, or into the home
> profile on standalone Home Manager. Session variables, the hyprland-session
> systemd target, the hy3 plugin load, and config auto-reload are handled by
> the home-manager module.

### Layout Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.hyprland.layout` | enum | `"dwindle"` | `"dwindle"`, `"master"`, `"scrolling"`, `"monocle"`, `"hy3"` |

- **dwindle** — spiral/bsp-style auto tiling; splits are preserved and toggleable
- **master** — one master window with stacked slaves; orientation cycles with `$mod+a`
- **scrolling** — ScrollWM-style full-height columns; mirrors the Scroll keybinds (`colresize`, `consume_or_expel`) and its animation profile
- **monocle** — single window at a time
- **hy3** — i3/Sway-style manual tiling (splits, tabbed/stacked groups, focus parent/child) via the [hy3](https://github.com/outfoxxed/hy3) plugin (`pkgs.hyprlandPlugins.hy3`), loaded automatically through home-manager's `plugins` option. If the plugin fails to load, the config falls back to `dwindle` and shows a notification.

### Layout-Specific Keybinds

Common binds (focus/move/resize, floating, fullscreen, pin, scratchpad,
screenshots, media, workspaces 1–10, mouse drag/resize) work in every layout.
The Sway layout/split binds map per layout:

| Keybind | dwindle | master | scrolling | monocle | hy3 |
|---------|---------|--------|-----------|---------|-----|
| `$mod + a` | toggle split | cycle orientation | – | – | toggle split h/v |
| `$mod + Alt + j` | split v (preselect) | – | move into column left | – | split v |
| `$mod + Alt + k` | split h (preselect) | – | move into column right | – | split h |
| `$mod + Alt + h` | – | – | column width 50% | – | stacked group |
| `$mod + Alt + l` | tabbed group | tabbed group | column width 100% | tabbed group | tabbed group |
| `$mod + Escape` | – | – | – | – | untab (default layout) |
| `$mod + Ctrl + a` | – | – | – | – | focus child |
| `$mod + Shift + a` | – | – | – | – | focus parent |

With `hy3`, focus/move follows i3 semantics (`hy3.move_focus` / `hy3.move_window`,
whole-group workspace moves, `$mod+q` kills the entire node), and special
workspaces plus the scratchpad (`special:scratchpad`) are shared with the
other layouts.

### Example

```nix
{
  minima = {
    enable = true;
    wm = "hyprland";
    hyprland.layout = "hy3";  # dwindle, master, scrolling, monocle, or hy3
  };
}
```

---

## Program Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.programs.terminal.name` | string | `"kitty"` | Terminal emulator name |
| `minima.programs.terminal.package` | package | `pkgs.kitty` | Terminal package |
| `minima.programs.fileManager.name` | string | `"dolphin"` | File manager name |
| `minima.programs.fileManager.package` | package | `pkgs.kdePackages.dolphin` | File manager package |
| `minima.programs.browser.name` | string | `"firefox"` | Browser name |
| `minima.programs.browser.package` | package | `pkgs.firefox` | Browser package |

### Example

```nix
{
  minima.programs = {
    terminal = {
      name = "kitty";
      package = pkgs.kitty;
    };
    fileManager = {
      name = "dolphin";
      package = pkgs.kdePackages.dolphin;
    };
    browser = {
      name = "firefox";
      package = pkgs.firefox;
    };
  };
}
```

---

## Display & Workspaces

### Display Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.displays` | attrs | `{}` | Attribute set of display configurations |
| `minima.displays.<name>.res` | string | `"preferred"` | Resolution (e.g., `"1920x1080"`) |
| `minima.displays.<name>.hz` | null/int | `null` | Refresh rate in Hz |
| `minima.displays.<name>.position.x` | int | `0` | X position |
| `minima.displays.<name>.position.y` | int | `0` | Y position |
| `minima.displays.<name>.scale` | float | `1.0` | Display scale |
| `minima.displays.<name>.workspace` | null/int/str | `null` | Workspace to assign to this output |

### Autostart

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.autostart` | list | `[]` | List of commands to autostart |

### Special Workspace Options

| Option | Type | Description |
|--------|------|-------------|
| `minima.specialWorkspaces` | attrs | `{}` | Attribute set of special workspace definitions |
| `minima.specialWorkspaces.<name>.key` | string | Key binding |
| `minima.specialWorkspaces.<name>.rule` | attrs | Window rules (e.g., `{ app_id = ["discord"]; class = ["Spotify"]; }`) |
| `minima.specialWorkspaces.<name>.autostart` | bool | Autostart app |
| `minima.specialWorkspaces.<name>.startCommand` | string | Command to run |

### Example

```nix
{
  minima.displays = {
    DP-1 = {
      res = "1920x1080";
      hz = 144;
      position.x = 0;
      position.y = 0;
      scale = 1.0;
      workspace = "1";
    };
    HDMI-A-1 = {
      res = "1920x1080";
      position.x = 1920;
      position.y = 0;
      scale = 1.0;
      workspace = "10";
    };
  };

  minima.autostart = [
    "discord"
  ];

  minima.specialWorkspaces = {
    discord = {
      key = "m";
      rule = {
        app_id = [ "discord" "WebCord" ];
        class = [ "discord" ];
      };
      autostart = true;
      startCommand = "discord";
    };
    spotify = {
      key = "s";
      rule = {
        class = [ "Spotify" ];
      };
    };
  };
}
```

---

## Desktop Integration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.desktop.enable` | bool | `true` | Enable desktop integration |
| `minima.desktop.xdgPortal` | bool | `true` | Enable XDG desktop portals |

---

## TeX/LaTeX

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.tex.enable` | bool | `false` | Enable texlive |
| `minima.tex.scheme` | null/string | `null` | Texlive scheme (e.g., `"scheme-full"`) |
| `minima.tex.packages` | null/attrs | `null` | Extra texlive packages |
| `minima.tex.spell` | list | `[]` | Language codes for vim spellfiles |

### Example

```nix
{
  minima.tex = {
    enable = true;
    scheme = "scheme-full";
    packages = {
      texlive-core = null;
      texlive-latexextra = null;
    };
    spell = [ "en" "de" ];
  };
}
```

---

## Panel & Launcher

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.minimaConfig.darkTheme` | bool | `true` | Use dark theme |
| `minima.minimaConfig.panel.enable` | bool | `true` | Enable panel |
| `minima.minimaConfig.panel.alwaysVisible` | bool | `true` | Panel always visible |
| `minima.minimaConfig.launcher.enable` | bool | `true` | Enable app launcher |
| `minima.minimaConfig.launcher.qalcPath` | string | `"${pkgs.libqalculate}/bin/qalc"` | Calculator path |
| `minima.minimaConfig.clipboard.enable` | bool | `true` | Enable clipboard manager |
| `minima.minimaConfig.wallpaper.enable` | bool | `true` | Enable wallpaper |
| `minima.minimaConfig.wallpaper.engineEnabled` | bool | `false` | Enable wallpaper engine |
| `minima.minimaConfig.wallpaper.workshopPath` | string | `"~/.steam/steam/steamapps/workshop/content/431960/"` | Workshop path |
| `minima.minimaConfig.wallpaper.fps` | int | `25` | Animation FPS |
| `minima.minimaConfig.wallpaper.fill` | bool | `true` | Fill mode |
| `minima.minimaConfig.wallpaper.matureContent` | bool | `false` | Mature content |

### Example

```nix
{
  minima.minimaConfig = {
    darkTheme = true;
    panel = {
      enable = true;
      alwaysVisible = true;
    };
    launcher = {
      enable = true;
      qalcPath = "${pkgs.libqalculate}/bin/qalc";
    };
    clipboard.enable = true;
    wallpaper = {
      enable = true;
      fill = true;
      fps = 60;
    };
  };
}
```

---

## Vim/Editor Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.vim.enable` | bool | `true` | Enable NixVim editor |
| `minima.vim.theme.name` | string | `"catppuccin"` | Color scheme name |
| `minima.vim.theme.flavour` | string | `"mocha"` | Theme flavour |

### LSP Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.vim.lsp.servers` | attrs | `{}` | Extra LSP servers configuration |
| `minima.vim.lsp.formatter` | attrs | `{}` | Extra conform `formatters_by_ft` entries by filetype |
| `minima.vim.lsp.formatterOpts` | attrs | `{}` | Formatter definitions (e.g. custom args) |

The editor is built on Nixvim with a gnvim-style layout: `nixvim/options.nix`,
`keymaps.nix`, `autocommands.nix`, `diagnostics.nix`, `performance.nix` and one
file per plugin under `nixvim/plugins/`. Language-specific config (LSP server,
linter, formatter) lives one file per language under `nixvim/languages/`.
Completion uses blink-cmp, LSP is
wired with inlay hints and `gd`/`gD`/`gi`/`K`/`<leader>ca` keymaps, formatting
uses conform-nvim, linting uses nvim-lint, and the UI is mini.nvim + lualine +
bufferline + noice. Any file dropped into `nixvim/plugins/*.nix` or
`nixvim/languages/*.nix` is imported
automatically.

### Keybindings

| Option | Type | Description |
|--------|------|-------------|
| `minima.vim.keybinds` | list | Extra keybindings |
| `minima.vim.keybinds[].mode` | string | Mode (`"n"`, `"i"`, `"v"`, `"t"`, etc.) |
| `minima.vim.keybinds[].key` | string | Key to bind |
| `minima.vim.keybinds[].action` | string | Action to execute |
| `minima.vim.keybinds[].desc` | string | Description |

### Autocmds

| Option | Type | Description |
|--------|------|-------------|
| `minima.vim.autocmd` | list | Extra autocommands |
| `minima.vim.autocmd[].event` | string/list | Event(s) to trigger on |
| `minima.vim.autocmd[].pattern` | string/list | File pattern |
| `minima.vim.autocmd[].command` | string | Command to run |

### Plugins

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minima.vim.plugins` | attrs | `{}` | Extra nixvim plugins |

### Example

```nix
{
  minima.vim = {
    enable = true;
    theme = {
      name = "catppuccin";
      flavour = "mocha";
    };
    lsp = {
      servers = {
        pyright = {};
        rust_analyzer = {};
      };
      formatter = {
        python = [ "black" ];
      };
    };
    keybinds = [
      {
        mode = "n";
        key = "<leader>tt";
        action = "<cmd>ToggleTerm direction=float<cr>";
        desc = "Floating terminal";
      }
    ];
    autocmd = [
      {
        event = "BufWritePre";
        pattern = "*.go";
        command = "lua vim.lsp.buf.format()";
      }
    ];
  };
}
```

### Default Vim Settings

The following settings are enabled by default in `nixvim/options.nix`:

- **Indentation**: `tabstop=2`, `shiftwidth=2`, `expandtab=true`, `autoindent=true`
- **UI**: `number`, `relativenumber`, `cursorline`, `cursorcolumn`, `signcolumn`, `splitright`, `splitbelow`, folding with custom fillchars
- **Clipboard**: `"unnamedplus"`
- **Search**: `incsearch`, `ignorecase`, `smartcase`

### Default Enabled Vim Plugins

- **UI**: catppuccin, mini.nvim (files/pick/surround/pairs/icons/...), lualine, bufferline, noice, smartcolumn
- **Completion**: blink-cmp (+ luasnip, friendly-snippets)
- **Syntax**: treesitter (all grammars)
- **Git**: gitsigns (line blame), lazygit, gitignore
- **LSP**: nvim-lsp (inlay hints), lsp-lines, lsp-signature, lspkind, trouble
- **Formatting/Linting**: conform-nvim, nvim-lint
- **Editing**: flash (disabled by default), smart-splits, toggleterm, comment via mini.ai/surround
- **Markdown**: render-markdown, image.nvim (kitty backend)
- **Nix**: direnv, nix, nix-develop
- **Misc**: trouble diagnostics, lint, performance byte-compilation

### Default LSP Servers

- `nixd` - Nix language server (flake-aware nixpkgs expr + nixfmt formatting)
- `lua_ls` - Lua language server
- `bashls`, `cssls`, `html`, `jsonls`, `marksman`, `pyright`, `yamlls`
- `ltex` - Grammar/spell checking
