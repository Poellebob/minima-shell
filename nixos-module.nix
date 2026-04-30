{ config, lib, pkgs, scroll-flake, ... }:

with lib;
let
  cfg = config.minima;
in {
  imports = [
    ./lib.nix
    ./lib-system.nix
    ./wm-config.nix
  ];

  config = mkMerge [
    (mkIf (cfg.enable && cfg.wm != null) {
      programs.sway = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx") {
        enable = true;
        wrapperFeatures.gtk = true;
        package = pkgs.${cfg.wm}.overrideAttrs (old: {
          buildCommand = ''
            ${old.buildCommand or ""}
            wrapProgram $out/bin/sway \
              ${lib.optionalString cfg.enableNvidia "--add-flags --unsupported-gpu"} \
              --add-flags "-c ${cfg.swayConfigFile}"
          '';
        });
        xwayland.enable = true;
      };

      programs.scroll = mkIf (cfg.enable && cfg.wm == "scroll") {
        enable = true;
        wrapperFeatures.gtk = true;
        package = pkgs.scroll.overrideAttrs (old: {
          buildCommand = ''
            ${old.buildCommand or ""}
            wrapProgram $out/bin/scroll \
              --add-flags "-c ${cfg.scrollConfigFile}"
          '';
        });
        xwayland.enable = true;
      };

      home-manager.sharedModules = [
        {
          minima = {
            wm                = mkDefault cfg.wm;
            osModule          = true;
            enableNvidia      = mkDefault cfg.enableNvidia;
            modifier          = mkDefault cfg.modifier;
            programs          = mkDefault cfg.programs;
            theming           = mkDefault cfg.theming;
            enableBranding    = mkDefault cfg.enableBranding;
            shell             = mkDefault cfg.shell;
            extraPackages     = mkDefault cfg.extraPackages;
            minimaConfig      = mkDefault cfg.minimaConfig;
            displays          = mkDefault cfg.displays;
            autostart         = mkDefault cfg.autostart;
            specialWorkspaces = mkDefault cfg.specialWorkspaces;
            tex               = mkDefault cfg.tex;
            desktop           = mkDefault cfg.desktop;
            # pass store paths so HM doesn't have to recompute them
            swayConfigFile    = mkDefault cfg.swayConfigFile;
            scrollConfigFile  = mkDefault cfg.scrollConfigFile;
            quickshellStoreDir = mkDefault cfg.quickshellStoreDir;
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

    (mkIf (cfg.desktop.xdgPortal) {
      environment.systemPackages = with pkgs; [
        kdePackages.plasma-workspace
      ];
      environment.etc."/xdg/menus/applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
      xdg.mime.enable = true;
      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
          pkgs.kdePackages.xdg-desktop-portal-kde
        ];
        config.common.default = [ "kde" "gtk" ];
      };
    })
  ];
}
