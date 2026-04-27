{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.minima;

  boolStr = b: if b then "true" else "false";
  boolInt = b: if b then "1" else "0";

  swayOutputBlock = name: d:
    let outputName = if name == "" then "*" else name; in ''
      output ${outputName} {
        res ${d.res}
        position ${toString d.position.x} ${toString d.position.y}
        scale ${toString d.scale}
      }'';

  swaySpecialWs = name: ws:
    let ruleStr = lib.concatStringsSep "," (lib.mapAttrsToList (k: vs: "${k}=${lib.concatStringsSep "|" vs}") ws.rule); in ''
      set $ws_${name} "${name}"
      ${optionalString ws.autostart "exec ${ws.startCommand}"}
      assign [${ruleStr}] workspace $ws_${name}
      for_window [${ruleStr}] set_size h 1.0
      bindsym ${cfg.modifier}+${ws.key} [workspace=$ws_${name}] move workspace to output current, workspace $ws_${name}
    '';

  swayfxConfig = ''
    shadows enable
    shadow_blur_radius 4
    shadow_color #1a1a1aee
    shadow_offset 0 2
    blur enable
    blur_radius 4
    blur_passes 2
    for_window [app_id=".*"] blur enable
    for_window [class=".*"] blur enable
  '';

in {
  config = mkIf cfg.enable {
    home.file.".config/minima/sway.conf" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx" || cfg.wm == "scroll") {
      text = ''
        set $mod ${cfg.modifier}
        set $fileManager ${cfg.programs.fileManager.name}
        set $browser ${cfg.programs.browser.name}

        ${concatMapStringsSep "\n" (x: swayOutputBlock x.name x.value) (mapAttrsToList (n: v: { name = n; value = v; }) cfg.displays)}

        ${concatMapStringsSep "\n" (x: "workspace ${toString x.value.workspace} output ${x.name}") (mapAttrsToList (n: v: { name = n; value = v; }) (filterAttrs (n: v: v.workspace != null) cfg.displays))}

        ${concatMapStringsSep "\n" (a: "exec ${a}") cfg.autostart}

        ${concatMapStringsSep "\n" (x: swaySpecialWs x.name x.value) (mapAttrsToList (n: v: { name = n; value = v; }) cfg.specialWorkspaces)}

        ${optionalString (cfg.wm == "swayfx") swayfxConfig}
      '';
    };

    home.file.".config/minima/config.ini" = {
      text = ''
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
    };

  };
}
