{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.minima;

  workspaceOutputType = types.submodule {
    options = {
      workspace = mkOption {
        type = types.str;
        description = "Workspace number or name";
        example = "1";
      };
      output = mkOption {
        type = types.str;
        example = "DP-1";
      };
    };
  };

  hyprMonitorLine = name: d:
    let
      resHz = if d.hz != null
        then "${d.res}@${toString d.hz}"
        else d.res;
      pos = if d.res == "preferred"
        then "auto"
        else "${toString d.position.x}x${toString d.position.y}";
    in
      "monitor = ${name},${resHz},${pos},${toString d.scale}";

  swayOutputBlock = name: d:
    let
      outputName = if name == "" then "*" else name;
    in ''
      output ${outputName} {
        res ${d.res}
        position ${toString d.position.x} ${toString d.position.y}
        scale ${toString d.scale}
      }'';

  swaySpecialWs = name: ws:
    let
      ruleStr = lib.concatStringsSep "," (lib.mapAttrsToList (k: vs: "${k}=${lib.concatStringsSep "|" vs}") ws.rule);
    in ''
    set $ws_${name} "${name}"
    ${optionalString ws.autostart "exec ${ws.startCommand}"}
    assign [${ruleStr}] workspace $ws_${name}
    for_window [${ruleStr}] set_size h 1.0
    bindsym ${cfg.modifier}+${ws.key} [workspace=$ws_${name}] move workspace to output current, workspace $ws_${name}
  '';

  swayfxConfig = ''
    # corner rounding
    corner_radius 8

    # window shadows
    shadows enable
    shadow_blur_radius 4
    shadow_color #1a1a1aee
    shadow_offset 0 2

    # blur
    blur enable
    blur_radius 4
    blur_passes 2

    for_window [app_id=".*"] blur enable
    for_window [class=".*"] blur enable
  '';

  boolStr = b: if b then "true" else "false";

in {
  config = mkIf cfg.enable {

    home.file.".config/minima/hypr.conf" = mkIf (cfg.wm == "hyprland") {
      text = ''
        $mainMod = ${cfg.modifier}
        $terminal = ${cfg.programs.terminal.name}
        $fileManager = ${cfg.programs.fileManager.name}
        $browser = ${cfg.programs.browser.name}
        $layout = ${cfg.hypr.layout}

        ${lib.concatMapStringsSep "\n" (x: hyprMonitorLine x.name x.value) (lib.mapAttrsToList (n: v: { name = n; value = v; }) cfg.displays)}

        ${lib.concatMapStringsSep "\n" (x: "workspace = ${toString x.value.workspace}, ${x.name}") (lib.mapAttrsToList (n: v: { name = n; value = v; }) (lib.filterAttrs (n: v: v.workspace != null) cfg.displays))}
      '';
    };

    home.file.".config/minima/sway.conf" = mkIf (cfg.wm == "sway" || cfg.wm == "swayfx" || cfg.wm == "scroll") {
      text = ''
        set $mod ${cfg.modifier}
        set $fileManager ${cfg.programs.fileManager.name}
        set $browser ${cfg.programs.browser.name}

        # display definitions
        ${lib.concatMapStringsSep "\n" (x: swayOutputBlock x.name x.value) (lib.mapAttrsToList (n: v: { name = n; value = v; }) cfg.displays)}

        # workspace → output assignments
        ${lib.concatMapStringsSep "\n" (x: "workspace ${toString x.value.workspace} output ${x.name}") (lib.mapAttrsToList (n: v: { name = n; value = v; }) (lib.filterAttrs (n: v: v.workspace != null) cfg.displays))}

        # autostart
        ${concatMapStringsSep "\n" (a: "exec ${a}") cfg.autostart}

        # special workspaces
        ${lib.concatMapStringsSep "\n" (x: swaySpecialWs x.name x.value) (lib.mapAttrsToList (n: v: { name = n; value = v; }) cfg.specialWorkspaces)}

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
