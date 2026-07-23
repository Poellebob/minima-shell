{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.minima;

  quickshellStoreDir = pkgs.runCommand "quickshell-config" { src = ./shell/interface; } ''
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

  minimaConfigJson = pkgs.writeText "minima-config.json" (builtins.toJSON {
    system = {
      wm = cfg.wm;
      matugenConfigPath = "${matugenConfigFile}";
      matugenBin = "${cfg.matugen.package}/bin/matugen";
    };
    theme = {
      darkTheme = cfg.minimaConfig.darkTheme;
    };
    panel = {
      enabled = cfg.minimaConfig.panel.enable;
      top = false;
      panelAlwaysVisible = cfg.minimaConfig.panel.alwaysVisible;
    };
    launcher = {
      enabled = cfg.minimaConfig.launcher.enable;
      qalcPath = cfg.minimaConfig.launcher.qalcPath;
    };
    clipboard = {
      enabled = cfg.minimaConfig.clipboard.enable;
    };
    wallpaper = {
      enabled = cfg.minimaConfig.wallpaper.enable;
      engineEnabled = cfg.minimaConfig.wallpaper.engineEnabled;
      enginePath = "${pkgs.linux-wallpaperengine}/bin/linux-wallpaperengine";
      workshopPath = cfg.minimaConfig.wallpaper.workshopPath;
      fps = cfg.minimaConfig.wallpaper.fps;
      fill = cfg.minimaConfig.wallpaper.fill;
      matureContent = cfg.minimaConfig.wallpaper.matureContent;
      volume = cfg.minimaConfig.wallpaper.volume;
    };
  });

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
    minima.minimaConfigFile = "${minimaConfigJson}";
    minima.matugenConfigFile = matugenConfigFile;
    minima.matugenTemplateFile = matugenTemplateFile;
  };
}
