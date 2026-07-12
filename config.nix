{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.minima;

  boolStr = b: if b then "true" else "false";

  quickshellStoreDir = pkgs.runCommand "quickshell-config" { src = ./shell/quickshell; } ''
    mkdir -p $out
    cd $src
    shopt -s dotglob
    for f in *; do
      cp -r "$f" $out/
    done
    chmod -R u+rw $out
  '';

  setXftDpi = pkgs.writeShellScript "set-xft-dpi.sh" (builtins.readFile ./set-xft-dpi.sh);

  autostart = ''

  '';

  minimaConfigIni = pkgs.writeText "minima-config.ini" ''
    [System]
    wm = ${cfg.wm}

    [Theme]
    darkTheme = ${boolStr cfg.minimaConfig.darkTheme}

    [Panel]
    enabled = ${boolStr cfg.minimaConfig.panel.enable}
    panelAlwaysVisible = ${boolStr cfg.minimaConfig.panel.alwaysVisible}

    [Launcher]
    enabled = ${boolStr cfg.minimaConfig.launcher.enable}
    qalcPath = ${cfg.minimaConfig.launcher.qalcPath}

    [Clipboard]
    enabled = ${boolStr cfg.minimaConfig.clipboard.enable}

    [Wallpaper]
    enabled = ${boolStr cfg.minimaConfig.wallpaper.enable}
    engineEnabled = ${boolStr cfg.minimaConfig.wallpaper.engineEnabled}
    enginePath = ${pkgs.linux-wallpaperengine}/bin/linux-wallpaperengine
    workshopPath = ${cfg.minimaConfig.wallpaper.workshopPath}
    fps = ${toString cfg.minimaConfig.wallpaper.fps}
    fill = ${boolStr cfg.minimaConfig.wallpaper.fill}
    matureContent = ${boolStr cfg.minimaConfig.wallpaper.matureContent}
  '';

  matugenTemplateFile = pkgs.writeText "quickshell.template.json" (builtins.readFile ./config/matugen/quickshell.template.json);

  matugenConfigFile = pkgs.writeText "matugen-config.toml" ''
    [config]
    mode = "${cfg.matugen.mode}"

    [templates.quickshell]
    input_path = "${matugenTemplateFile}"
    output_path = "~/.config/minima/colors.json"

    [colors]
    source = "${cfg.matugen.sourceColor}"
    scheme = "${cfg.matugen.scheme}"
  '';

  mkWmConfig = import ./config/sway/config.nix { inherit cfg pkgs lib quickshellStoreDir setXftDpi; };

in {
  config = mkIf cfg.enable {
    minima.swayConfigFile = mkWmConfig "sway";
    minima.scrollConfigFile = mkWmConfig "scroll";

    minima.quickshellStoreDir = quickshellStoreDir;
    minima.minimaConfigFile = "${minimaConfigIni}";
    minima.matugenConfigFile = matugenConfigFile;
    minima.matugenTemplateFile = matugenTemplateFile;
  };
}
