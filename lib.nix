{ lib, pkgs, ... }:

with lib;
let
  displayType = types.submodule {
    options = {
      name     = mkOption { type = types.str;   default = ""; };
      res      = mkOption { type = types.str;   default = "preferred"; };
      hz       = mkOption { type = types.nullOr types.int; default = null; };
      position = {
        x = mkOption { type = types.int; default = 0; };
        y = mkOption { type = types.int; default = 0; };
      };
      scale = mkOption { type = types.float; default = 1.0; };
    };
  };

  workspaceOutputType = types.submodule {
    options = {
      workspace = mkOption { type = types.str; };
      output    = mkOption { type = types.str; };
    };
  };

  specialWorkspaceType = types.submodule {
    options = {
      name         = mkOption { type = types.str; };
      key          = mkOption { type = types.str; };
      rule         = mkOption { type = types.str; };
      autostart    = mkOption { type = types.bool; default = false; };
      startCommand = mkOption { type = types.str;  default = ""; };
    };
  };

in
{
  options.minima = {
    enable = mkEnableOption "Minima shell";

    wm = mkOption {
      type = types.enum [ "sway" "swayfx" "scroll" "hyprland" ];
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
    hypr.layout    = mkOption {
      type = types.enum [ "dwindle" "master" ];
      default = "dwindle";
      internal = true;
    };
    displays = mkOption {
      type = types.listOf displayType;
      default = [];
      internal = true;
    };
    workspaceOutputs = mkOption {
      type = types.listOf workspaceOutputType;
      default = [];
      internal = true;
    };
    autostart = mkOption {
      type = types.listOf types.str;
      default = [];
      internal = true;
    };
    specialWorkspaces = mkOption {
      type = types.listOf specialWorkspaceType;
      default = [];
      internal = true;
    };

    theming.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hardcoded Minima styling (Breeze/Papirus/Rose-Pine)";
    };

    enableBranding = mkOption {
      type = types.bool;
      default = true;
      description = "Show 'minima' as XDG_CURRENT_DESKTOP";
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
        description = "Extra texlive packages as an attrset, e.g. { inherit (pkgs.texlive) dvisvgm dvipng; }";
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
        enginePath    = mkOption { type = types.str;  default = ""; };
        workshopPath  = mkOption {
          type    = types.str;
          default = "~/.steam/steam/steamapps/workshop/content/431960/";
        };
        fps           = mkOption { type = types.int;  default = 25; };
        fill          = mkOption { type = types.bool; default = true; };
        matureContent = mkOption { type = types.bool; default = false; };
      };
    };
  };
}
