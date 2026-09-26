{
  config,
  lib,
  pkgs,
  ...
}:

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

  minimaConfigJson = pkgs.writeText "minima-config.json" (
    builtins.toJSON {
      system = {
        wm = if wm == null then "sway" else wm;
        matugenConfigPath = "${matugenConfigFile}";
        matugenBin = "${cfg.matugen.package}/bin/matugen";
      };
      theme = {
        darkTheme = cfg.darkTheme;
      };
      panel = {
        enabled = cfg.panel.enable;
        top = true;
        panelAlwaysVisible = cfg.panel.alwaysVisible;
      };
      launcher = {
        enabled = cfg.launcher.enable;
        qalcPath = cfg.launcher.qalcPath;
      };
      clipboard = {
        enabled = cfg.clipboard.enable;
      };
      wallpaper = {
        enabled = cfg.wallpaper.enable;
        engineEnabled = cfg.wallpaper.engineEnabled;
        enginePath = "${pkgs.linux-wallpaperengine}/bin/linux-wallpaperengine";
        workshopPath = cfg.wallpaper.workshopPath;
        fps = cfg.wallpaper.fps;
        fill = cfg.wallpaper.fill;
        matureContent = cfg.wallpaper.matureContent;
        volume = cfg.wallpaper.volume;
      };
    }
  );

  matugenTemplateFile = pkgs.writeText "quickshell.template.json" (
    builtins.readFile ./config/matugen/quickshell.template.json
  );

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

  wm =
    if cfg.hyprland.enable then
      "hyprland"
    else if cfg.sway.enable then
      (if cfg.sway.fx then "swayfx" else "sway")
    else if cfg.scroll.enable then
      "scroll"
    else
      null;

  mkSwayConfig = import ./config/sway/config.nix {
    inherit
      cfg
      pkgs
      lib
      ;
  };
  mkHyprlandConfig = import ./config/hyprland/hyprland.nix {
    inherit
      cfg
      pkgs
      lib
      ;
  };
in
{
  config = mkIf cfg.enable {
    minima.hyprland.enable = mkIf (cfg.sway.enable || cfg.scroll.enable) (mkDefault false);
    minima.sway.enable = mkIf cfg.sway.fx (mkDefault true);

    minima.swayConfigFile = mkIf cfg.sway.enable (
      mkSwayConfig (if cfg.sway.fx then "swayfx" else "sway") cfg.sway.extraConfig
    );
    minima.scrollConfigFile = mkIf cfg.scroll.enable (mkSwayConfig "scroll" cfg.scroll.extraConfig);
    minima.hyprlandLua = mkIf cfg.hyprland.enable mkHyprlandConfig;

    minima.quickshellStoreDir = quickshellStoreDir;
    minima.minimaConfigFile = "${minimaConfigJson}";
    minima.matugenConfigFile = matugenConfigFile;
    minima.matugenTemplateFile = matugenTemplateFile;
  };
}
