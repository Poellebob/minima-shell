{ config, lib, pkgs, inputs, scroll-flake, ... }:

with lib;
let
  cfg = config.minima;
in {
  imports = [
    ./lib.nix
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
            programs              = mkDefault cfg.programs;
            hypr.layout       = mkDefault cfg.hypr.layout;
            theming          = mkDefault cfg.theming;
            enableBranding   = mkDefault cfg.enableBranding;
            shell           = mkDefault cfg.shell;
            extraPackages    = mkDefault cfg.extraPackages;
            minimaConfig    = mkDefault cfg.minimaConfig;
            displays          = mkDefault cfg.displays;
            workspaceOutputs  = mkDefault cfg.workspaceOutputs;
            autostart         = mkDefault cfg.autostart;
            specialWorkspaces = mkDefault cfg.specialWorkspaces;
            tex               = mkDefault cfg.tex;
            desktop           = mkDefault cfg.desktop;
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
    (mkIf cfg.desktop.xdgPortal {
      environment.systemPackages = with pkgs; [
        kdePackages.plasma-workspace
      ];
      environment.etc."/xdg/menus/applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
      xdg.mime.enable = true;
      xdg.portal = {
        enable = true;
        wlr.enable = true;
      };
    })
  ];
}
