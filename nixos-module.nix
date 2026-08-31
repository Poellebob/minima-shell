{ config, lib, pkgs, scroll-flake, ... }:

with lib;
let
  cfg = config.minima;
in {
  imports = [
    ./lib.nix
    ./lib-system.nix
    ./config.nix
  ];

  config = mkMerge [
    (mkIf cfg.enable {
      programs.hyprland = mkIf cfg.hyprland.enable {
        enable = true;
      };

      programs.sway = mkIf cfg.sway.enable {
        enable = true;
        wrapperFeatures.gtk = true;
        package = (if cfg.sway.fx then pkgs.swayfx else pkgs.sway).overrideAttrs (old: {
          buildCommand = ''
            ${old.buildCommand or ""}
            wrapProgram $out/bin/sway \
              ${lib.optionalString cfg.enableNvidia "--add-flags --unsupported-gpu"}
          '';
        });
        xwayland.enable = true;
      };

      programs.scroll = mkIf cfg.scroll.enable {
        enable = true;
        wrapperFeatures.gtk = true;
        package = scroll-flake.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
          buildCommand = ''
            ${old.buildCommand or ""}
            wrapProgram $out/bin/scroll
          '';
        });
        xwayland.enable = true;
      };



      home-manager.sharedModules = [
        {
          minima = {
            osModule          = true;
            enableNvidia      = mkDefault cfg.enableNvidia;
            programs          = mkDefault cfg.programs;
            theming           = mkDefault cfg.theming;
            shell             = mkDefault cfg.shell;
            extraPackages     = mkDefault cfg.extraPackages;
            minimaConfig      = mkDefault cfg.minimaConfig;
            displays          = mkDefault cfg.displays;
            autostart         = mkDefault cfg.autostart;
            specialWorkspaces = mkDefault cfg.specialWorkspaces;
            tex               = mkDefault cfg.tex;
            desktop           = mkDefault cfg.desktop;

            hyprland = {
              enable = cfg.hyprland.enable;
              modifier = mkDefault cfg.hyprland.modifier;
              layout = mkDefault cfg.hyprland.layout;
              extraLua = mkDefault cfg.hyprland.extraLua;
              plugins = mkDefault cfg.hyprland.plugins;
            };
            sway = {
              enable = cfg.sway.enable;
              modifier = mkDefault cfg.sway.modifier;
              fx = mkDefault cfg.sway.fx;
              extraConfig = mkDefault cfg.sway.extraConfig;
            };
            scroll = {
              enable = cfg.scroll.enable;
              modifier = mkDefault cfg.scroll.modifier;
              extraConfig = mkDefault cfg.scroll.extraConfig;
            };

            swayConfigFile    = mkDefault cfg.swayConfigFile;
            scrollConfigFile  = mkDefault cfg.scrollConfigFile;
            quickshellStoreDir = mkDefault cfg.quickshellStoreDir;
            matugenConfigFile = mkDefault cfg.matugenConfigFile;
            matugenTemplateFile = mkDefault cfg.matugenTemplateFile;
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
