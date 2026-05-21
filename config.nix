{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.minima;

  boolStr = b: if b then "true" else "false";

  swayOutputBlock = name: d:
    let outputName = if name == "" then "*" else name; in ''
      output ${outputName} {
        res ${d.res}
        position ${toString d.position.x} ${toString d.position.y}
        scale ${toString d.scale}
      }'';

  swaySpecialWs = name: ws:
    let
      ruleStrings = lib.mapAttrsToList (k: vs: ''${k}="${lib.concatStringsSep "|" vs}"'') ws.rule;
      assigns = lib.concatMapStringsSep "\n      " (r: "assign [${r}] workspace $ws_${name}") ruleStrings;
      forWindows = lib.concatMapStringsSep "\n      " (r: "for_window [${r}] set_size h 1.0") ruleStrings;
    in ''
      set $ws_${name} "${name}"
      ${optionalString ws.autostart "exec ${ws.startCommand}"}
      ${assigns}
      ${forWindows}
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

  swayConfText = ''
    set $mod ${cfg.modifier}
    set $fileManager ${cfg.programs.fileManager.name}
    set $browser ${cfg.programs.browser.name}
    set $terminal ${cfg.programs.terminal.name}
    set $qs_path ${quickshellStoreDir}

    ${concatMapStringsSep "\n" (x: swayOutputBlock x.name x.value) (mapAttrsToList (n: v: { name = n; value = v; }) cfg.displays)}

    ${concatMapStringsSep "\n" (x: "workspace ${toString x.value.workspace} output ${x.name}") (mapAttrsToList (n: v: { name = n; value = v; }) (filterAttrs (n: v: v.workspace != null) cfg.displays))}

    ${concatMapStringsSep "\n" (a: "exec ${a}") cfg.autostart}

    ${concatMapStringsSep "\n" (x: swaySpecialWs x.name x.value) (mapAttrsToList (n: v: { name = n; value = v; }) cfg.specialWorkspaces)}

    ${optionalString (cfg.wm == "swayfx") swayfxConfig}
  '';

  quickshellStoreDir = pkgs.runCommand "quickshell-config" { src = ./shell/quickshell; } ''
    mkdir -p $out
    cd $src
    shopt -s dotglob
    for f in *; do
      cp -r "$f" $out/
    done
    chmod -R u+rw $out
  '';

  setXftDpi = pkgs.writeShellScript "set-xft-dpi.sh" (builtins.readFile ./shell/set-xft-dpi.sh);

  autostart = ''
    exec swww-daemon
    exec ${pkgs.quickshell}/bin/qs -c $qs_path
    exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    exec /usr/lib/polkit-kde-authentication-agent-1
    exec wl-paste --watch cliphist store
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

in {
  config = mkIf cfg.enable {
    minima.swayConfigFile = pkgs.writeText "sway-config" ''
      ${swayConfText}

      ${builtins.readFile ./config/sway/config.d/keybinds}
      ${builtins.readFile ./config/sway/config.d/workspace}
      ${builtins.readFile ./config/sway/config.d/application-behavior}
      ${builtins.readFile ./config/sway/config.d/env}
      ${builtins.readFile ./config/sway/config.d/input}
      ${builtins.readFile ./config/sway/config.d/application-style}

      ${autostart}
      exec_always --no-startup-id sh -c 'swaymsg input type:keyboard xkb_layout "$(localectl status | sed -n "s/^\s*X11 Layout:\s*//p")"'
      exec ${setXftDpi}
    '';

    minima.scrollConfigFile = pkgs.writeText "scroll-config" ''
      ${swayConfText}

      ${builtins.readFile ./config/scroll/config.d/keybinds}
      ${builtins.readFile ./config/scroll/config.d/workspace}
      ${builtins.readFile ./config/scroll/config.d/application-behavior}
      ${builtins.readFile ./config/scroll/config.d/env}
      ${builtins.readFile ./config/scroll/config.d/input}
      ${builtins.readFile ./config/scroll/config.d/application-style}

      ${autostart}
      exec_always --no-startup-id sh -c 'scrollmsg input type:keyboard xkb_layout "$(localectl status | sed -n "s/^\s*X11 Layout:\s*//p")"'
      exec ${setXftDpi}
    '';

    minima.quickshellStoreDir = quickshellStoreDir;
    minima.minimaConfigFile = "${minimaConfigIni}";
    minima.matugenConfigFile = matugenConfigFile;
    minima.matugenTemplateFile = matugenTemplateFile;
  };
}
