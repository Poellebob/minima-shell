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

  setXftDpi =
    { scale }:
    pkgs.writeShellScript "set-xft-dpi.sh" ''
      export SCALE=${toString scale}
      ${builtins.readFile ./set-xft-dpi.sh}
    '';

  minimaConfigJson = pkgs.writeText "minima-config.json" (builtins.toJSON {
    system = {
      wm = if wm == null then "sway" else wm;
      matugenConfigPath = "${matugenConfigFile}";
      matugenBin = "${cfg.matugen.package}/bin/matugen";
    };
    theme = {
      darkTheme = cfg.minimaConfig.darkTheme;
    };
    panel = {
      enabled = cfg.minimaConfig.panel.enable;
      top = true;
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

  wm =
    if cfg.hyprland.enable then "hyprland"
    else if cfg.sway.enable then (if cfg.sway.fx then "swayfx" else "sway")
    else if cfg.scroll.enable then "scroll"
    else null;

  mkWmConfig = import ./config/sway/config.nix { inherit cfg pkgs lib quickshellStoreDir setXftDpi; };
  mkHyprlandConfig = import ./config/hyprland/hyprland.nix { inherit cfg pkgs lib quickshellStoreDir setXftDpi; };
in {
  config = mkIf cfg.enable {
    minima.hyprland.enable = mkIf (cfg.sway.enable || cfg.scroll.enable) (mkDefault false);
    minima.sway.enable = mkIf cfg.sway.fx (mkDefault true);

    minima.swayConfigFile = mkIf cfg.sway.enable (mkWmConfig (if cfg.sway.fx then "swayfx" else "sway") cfg.sway.extraConfig);
    minima.scrollConfigFile = mkIf cfg.scroll.enable (mkWmConfig "scroll" cfg.scroll.extraConfig);
    minima.hyprlandLua = mkIf cfg.hyprland.enable mkHyprlandConfig;
    minima.hyprland.plugins = mkIf (cfg.hyprland.enable && cfg.hyprland.layout == "hy3") [ pkgs.hyprlandPlugins.hy3 ];

    minima.quickshellStoreDir = quickshellStoreDir;
    minima.minimaConfigFile = "${minimaConfigJson}";
    minima.matugenConfigFile = matugenConfigFile;
    minima.matugenTemplateFile = matugenTemplateFile;
  };
}
