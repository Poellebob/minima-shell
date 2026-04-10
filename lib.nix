{ lib, pkgs, ... }:

with lib;
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
    apps.fileManager = mkOption { type = types.str;  default = "dolphin"; internal = true; };
    apps.browser     = mkOption { type = types.str;  default = "zen-browser"; internal = true; };
    hypr.layout    = mkOption {
      type = types.enum [ "dwindle" "master" ];
      default = "dwindle";
      internal = true;
    };
    displays = mkOption {
      type = types.listOf types.anything;
      default = [];
      internal = true;
    };
    workspaceOutputs = mkOption {
      type = types.listOf types.anything;
      default = [];
      internal = true;
    };
    autostart = mkOption {
      type = types.listOf types.str;
      default = [];
      internal = true;
    };
    specialWorkspaces = mkOption {
      type = types.listOf types.anything;
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

    terminal = {
      name    = mkOption { type = types.str;     default = "kitty"; };
      package = mkOption { type = types.package; default = pkgs.kitty; };
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
        engineEnabled = mkOption { type = types.bool; default = false; };
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
