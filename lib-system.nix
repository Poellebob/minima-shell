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

in {
  options.minima = {
    wm = mkOption {
      type = types.enum [ "sway" "swayfx" "scroll" "hyprland" ];
      default = "sway";
      description = "Window manager / compositor to use.";
    };

    enableNvidia = mkOption {
      type = types.bool;
      default = false;
    };

    modifier = mkOption {
      type = types.str;
      default = "Mod4";
    };

    apps = {
      fileManager = mkOption { type = types.str; default = "dolphin"; };
      browser     = mkOption { type = types.str; default = "zen-browser"; };
    };

    hypr.layout = mkOption {
      type = types.enum [ "dwindle" "master" ];
      default = "dwindle";
    };

    displays = mkOption {
      type = types.listOf displayType;
      default = [];
    };

    workspaceOutputs = mkOption {
      type = types.listOf workspaceOutputType;
      default = [];
    };

    autostart = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    specialWorkspaces = mkOption {
      type = types.listOf specialWorkspaceType;
      default = [];
    };
  };
}