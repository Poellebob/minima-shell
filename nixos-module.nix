{ config, lib, pkgs, inputs, scroll-flake, ... }:

with lib;
let
  cfg = config.minima;
in {
  imports = [
    ./lib-system.nix
  ];

  config = mkMerge [
    (mkIf (cfg.wm != null) {
      programs.sway = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") {
        enable = true;
        wrapperFeatures.gtk = true;
      };
      programs.hyprland = mkIf (cfg.wm == "hyprland") {
        enable = true;
      };
      programs.scroll = mkIf (cfg.wm == "scroll") {
        enable = true;
        wrapperFeatures.gtk = true;
      };
      home-manager.sharedModules = [
        {
          minima = {
            wm                = mkDefault cfg.wm;
            enableNvidia      = mkDefault cfg.enableNvidia;
            modifier          = mkDefault cfg.modifier;
            apps              = mkDefault cfg.apps;
            hypr.layout       = mkDefault cfg.hypr.layout;
            displays          = mkDefault cfg.displays;
            workspaceOutputs  = mkDefault cfg.workspaceOutputs;
            autostart         = mkDefault cfg.autostart;
            specialWorkspaces = mkDefault cfg.specialWorkspaces;
            tex               = mkDefault cfg.tex;
          };
        }
      ];
    })
    (mkIf cfg.tex.enable {
      environment.systemPackages = [
        (pkgs.texlive.combine (
          { ${cfg.tex.scheme} = pkgs.texlive.${cfg.tex.scheme}; }
          // optionalAttrs (cfg.tex.packages != null) cfg.tex.packages
        ))
      ];
    })
  ];
}
