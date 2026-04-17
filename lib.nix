{ lib, pkgs, ... }:

with lib;
let
  dolphinOverlaySpec = final: prev: {
    kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
      dolphin = prev.symlinkJoin {
        name = "dolphin-wrapped";
        paths = [
          kprev.dolphin
          kprev.ark
          kprev.kio
          kprev.kio-fuse
          kprev.kio-extras
          kprev.kservice
          kprev.kde-cli-tools
          kprev.kfilemetadata
          kprev.solid
        ];
        nativeBuildInputs = [ prev.makeWrapper ];
        postBuild = ''
          rm $out/bin/dolphin
          makeWrapper ${kprev.dolphin}/bin/dolphin $out/bin/dolphin \
            --set XDG_CONFIG_DIRS "${kprev.kservice}/etc/xdg:$XDG_CONFIG_DIRS"
        '';
      };
    });
  };
  pkgsPatched = pkgs.extend dolphinOverlaySpec;
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
        package = mkOption { type = types.package; default = pkgsPatched.kdePackages.dolphin; };
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
