{ lib, pkgs, ... }:

with lib;
let
  displayType = types.submodule {
    options = {
      res      = mkOption { type = types.str;   default = "preferred"; };
      hz       = mkOption { type = types.nullOr types.int; default = null; };
      position = {
        x = mkOption { type = types.int; default = 0; };
        y = mkOption { type = types.int; default = 0; };
      };
      scale = mkOption { type = types.float; default = 1.0; };
      workspace = mkOption { type = types.nullOr (types.either types.int types.str); default = null; };
    };
  };

  specialWorkspaceType = types.submodule {
    options = {
      key          = mkOption { type = types.str; };
      rule = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = {};
      };
      autostart    = mkOption { type = types.bool; default = false; };
      startCommand = mkOption { type = types.str;  default = ""; };
    };
  };
in
{
  options.minima = {
    enable = mkEnableOption "Minima shell";

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

    wm = mkOption {
      type = types.enum [ "sway" "swayfx" "scroll" ];
      default = "sway";
      internal = true;
    };
    enableNvidia   = mkOption { type = types.bool;   default = false; internal = true; };
    modifier       = mkOption { type = types.str;    default = "Mod4"; internal = true; };
    programs = {
      terminal = {
        name    = mkOption { type = types.str;     default = "kitty"; };
        package = mkOption { type = types.package; default = pkgs.kitty; };
      };

      fileManager = {
        name    = mkOption { type = types.str;     default = "dolphin"; };
        package = mkOption { type = types.package; default = pkgs.kdePackages.dolphin; };
      };

      browser = {
        name    = mkOption { type = types.str;     default = "firefox"; };
        package = mkOption { type = types.package; default = pkgs.firefox; };
      };
    };

    displays = mkOption {
      type = types.attrsOf displayType;
      default = {};
      internal = true;
    };
    autostart = mkOption {
      type = types.listOf types.str;
      default = [];
    };
    specialWorkspaces = mkOption {
      type = types.attrsOf specialWorkspaceType;
      default = {};
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
      default = [];
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
        default = [];
        description = "List of language codes for neovim spellfiles";
      };
    };

    minimaConfig = {
      darkTheme = mkOption { type = types.bool; default = true; };

      panel = {
        enable        = mkOption { type = types.bool; default = true; };
        alwaysVisible = mkOption { type = types.bool; default = true; };
      };

      launcher = {
        enable = mkOption { type = types.bool; default = true; };
        qalcPath = mkOption { type = types.str; default = "${pkgs.libqalculate}/bin/qalc"; };
      };

      clipboard.enable = mkOption { type = types.bool; default = true; };

      wallpaper = {
        enable        = mkOption { type = types.bool; default = true; };
        engineEnabled = mkOption {
          description = "Enable wallpaper engine support";
          type = types.bool;
          default = false;
        };
        workshopPath  = mkOption {
          type    = types.str;
          default = "~/.steam/steam/steamapps/workshop/content/431960/";
        };
        fps           = mkOption { type = types.int;  default = 25; };
        fill          = mkOption { type = types.bool; default = true; };
        matureContent = mkOption { type = types.bool; default = false; };
        volume        = mkOption { type = types.int;  default = 50; };
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
