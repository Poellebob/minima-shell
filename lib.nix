{ lib, pkgs, ... }:

with lib;
let
  displayType = types.submodule {
    options = {
      res = mkOption {
        type = types.str;
        default = "preferred";
      };
      hz = mkOption {
        type = types.nullOr types.int;
        default = null;
      };
      position = {
        x = mkOption {
          type = types.int;
          default = 0;
        };
        y = mkOption {
          type = types.int;
          default = 0;
        };
      };
      scale = mkOption {
        type = types.float;
        default = 1.0;
      };
      workspace = mkOption {
        type = types.nullOr (types.either types.int types.str);
        default = null;
      };
      primary = mkOption {
        type = types.bool;
        default = false;
        description = "Mark this display as the primary monitor (mouse spawns here)";
      };
    };
  };

  specialWorkspaceType = types.submodule {
    options = {
      keybind = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      rule = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = { };
      };
      autostart = mkOption {
        type = types.bool;
        default = false;
      };
      startCommand = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  keybindType = types.submodule {
    options = {
      exec = mkOption { type = types.str; };
      bind = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      type = mkOption {
        type = types.str;
        default = "bindsym";
        description = "Bind command type (only used by sway/scroll)";
      };
      raw = mkOption {
        type = types.bool;
        default = false;
        description = "Emit exec verbatim: raw Lua for hyprland, raw sway command for sway/scroll (skips exec_cmd / exec wrapping)";
      };
    };
  };
in
{
  options.minima = {
    enable = mkEnableOption "Minima shell";

    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Hyprland as the window manager. Automatically disabled when sway or scroll is enabled, unless set explicitly.";
      };
      modifier = mkOption {
        type = types.str;
        default = "SUPER";
        description = "Hyprland modifier key";
      };
      layout = mkOption {
        type = types.enum [ "dwindle" "master" "scrolling" "hy3" ];
        default = "dwindle";
        description = "Hyprland layout";
      };
      extraLua = mkOption {
        type = types.lines;
        default = "";
        description = "Extra Lua appended to the generated Hyprland config";
      };
      plugins = mkOption {
        type = types.listOf (types.either types.package (types.strMatching "/.*"));
        default = [ ];
        description = "Hyprland plugins (packages or absolute paths)";
      };
    };

    sway = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Sway as the window manager";
      };
      modifier = mkOption {
        type = types.str;
        default = "Mod4";
        description = "Sway modifier key";
      };
      fx = mkOption {
        type = types.bool;
        default = false;
        description = "Use swayfx (blur, shadows)";
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra sway config appended to the generated config";
      };
    };

    scroll = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Scroll as the window manager";
      };
      modifier = mkOption {
        type = types.str;
        default = "Mod4";
        description = "Scroll modifier key";
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra scroll config appended to the generated config";
      };
    };

    osModule = mkOption {
      type = types.bool;
      default = false;
      internal = true;
    };

    minimaConfigFile = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    swayConfigFile = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    scrollConfigFile = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    quickshellStoreDir = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    hyprlandLua = mkOption {
      type = types.nullOr types.str;
      default = null;
      internal = true;
    };

    enableNvidia = mkOption {
      type = types.bool;
      default = false;
      internal = true;
    };
    keybinds = mkOption {
      type = types.listOf keybindType;
      default = [ ];
      description = "Global keybindings using common modifier names (Main, Shift, Ctrl, Alt).";
    };

    kitty = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kitty terminal config";
      };
    };

    programs = {
      terminal = {
        name = mkOption {
          type = types.str;
          default = "kitty";
          description = "Terminal application name (used for KDE defaults and env vars)";
        };
        package = mkOption {
          type = types.package;
          default = pkgs.kitty;
          description = "Terminal application package";
        };
      };
    };

    displays = mkOption {
      type = types.attrsOf displayType;
      default = { };
      internal = true;
    };
    autostart = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
    specialWorkspaces = mkOption {
      type = types.attrsOf specialWorkspaceType;
      default = { };
    };

    theming.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hardcoded Minima styling (Breeze/Papirus/Rose-Pine)";
    };

    shell.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh, fzf, starship, etc.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };

    desktop = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable desktop integration (Dolphin, XDG portals, KDE packages)";
      };
      xdgPortal = mkOption {
        type = types.bool;
        default = true;
        description = "Enable XDG desktop portals (kde + gtk)";
      };
    };

    tex = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable texlive";
      };
      scheme = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Texlive scheme name, e.g. \"scheme-full\"";
      };
      packages = mkOption {
        type = types.nullOr (types.attrsOf types.anything);
        default = null;
        description = "Extra texlive packages as an attrset";
      };
      spell = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of language codes for neovim spellfiles";
      };
    };

    minimaConfig = {
      darkTheme = mkOption {
        type = types.bool;
        default = true;
      };

      panel = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
        alwaysVisible = mkOption {
          type = types.bool;
          default = true;
        };
      };

      launcher = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
        qalcPath = mkOption {
          type = types.str;
          default = "${pkgs.libqalculate}/bin/qalc";
        };
      };

      clipboard.enable = mkOption {
        type = types.bool;
        default = true;
      };

      wallpaper = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
        engineEnabled = mkOption {
          description = "Enable wallpaper engine support";
          type = types.bool;
          default = false;
        };
        workshopPath = mkOption {
          type = types.str;
          default = "~/.steam/steam/steamapps/workshop/content/431960/";
        };
        fps = mkOption {
          type = types.int;
          default = 25;
        };
        fill = mkOption {
          type = types.bool;
          default = true;
        };
        matureContent = mkOption {
          type = types.bool;
          default = false;
        };
        volume = mkOption {
          type = types.int;
          default = 50;
        };
      };
    };

    matugenConfigFile = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    matugenTemplateFile = mkOption {
      type = types.nullOr types.package;
      default = null;
      internal = true;
    };

    matugen = {
      sourceColor = mkOption {
        type = types.str;
        default = "#6750A4";
        description = "Seed color for matugen";
      };
      scheme = mkOption {
        type = types.str;
        default = "content";
        description = "Matugen color scheme type";
      };
      mode = mkOption {
        type = types.str;
        default = "color";
        description = "Matugen mode (color/image)";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.matugen;
        description = "Matugen package";
      };
    };
  };
}
