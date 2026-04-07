{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.minima;
in {
  imports = [
    ./lib.nix
  ];

  config = mkIf cfg.enable {
    programs.sway = mkIf (cfg.wm == "sway") {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [];
    };

    programs.swayfx = mkIf (cfg.wm == "swayfx") {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [];
    };

    programs.hyprland = mkIf (cfg.wm == "hyprland") {
      enable = true;
    };

    programs.scroll = mkIf (cfg.wm == "scroll") {
      enable = true;
    };
  };
}
