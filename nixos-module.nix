{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.minima;
in {
  imports = [
    ./lib.nix
  ];

  config = mkIf cfg.enable {
    warnings = mkIf (cfg.wm == "scroll") [
      "minima: scroll is installed from https://github.com/AsahiRocks/scroll-flake which is ARCHIVED and UNMAINTAINED."
      "minima: scroll may be outdated or broken. Use at your own risk."
    ];

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
      package = inputs.scroll-flake.packages.${pkgs.stdenv.hostPlatform.system}.scroll-stable;
    };
  };
}
