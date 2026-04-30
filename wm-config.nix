{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.minima;

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

  swayConfText = ''
    set $mod ${cfg.modifier}
    set $fileManager ${cfg.programs.fileManager.name}
    set $browser ${cfg.programs.browser.name}

    ${concatMapStringsSep "\n" (x: swayOutputBlock x.name x.value) (mapAttrsToList (n: v: { name = n; value = v; }) cfg.displays)}

    ${concatMapStringsSep "\n" (x: "workspace ${toString x.value.workspace} output ${x.name}") (mapAttrsToList (n: v: { name = n; value = v; }) (filterAttrs (n: v: v.workspace != null) cfg.displays))}

    ${concatMapStringsSep "\n" (a: "exec ${a}") cfg.autostart}

    ${concatMapStringsSep "\n" (x: swaySpecialWs x.name x.value) (mapAttrsToList (n: v: { name = n; value = v; }) cfg.specialWorkspaces)}

    ${optionalString (cfg.wm == "swayfx") swayfxConfig}
  '';

  quickshellStoreDir = pkgs.runCommand "quickshell-config" { src = ./config/quickshell; } ''
    mkdir -p $out
    cd $src
    shopt -s dotglob
    for f in *; do
      cp -r "$f" $out/
    done
    chmod -R u+rw $out
  '';

  setXftDpiSway   = pkgs.writeShellScript "set-xft-dpi-sway.sh"   (builtins.readFile ./config/sway/set-xft-dpi.sh);
  setXftDpiScroll = pkgs.writeShellScript "set-xft-dpi-scroll.sh" (builtins.readFile ./config/scroll/set-xft-dpi.sh);

  autostart = ''
    exec swww-daemon
    exec ${pkgs.quickshell}/bin/qs -c ${quickshellStoreDir}
    exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    exec /usr/lib/polkit-kde-authentication-agent-1
    exec wl-paste --watch cliphist store
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
      set $terminal ${cfg.programs.terminal.name}

      ${autostart}
      exec_always --no-startup-id sh -c 'swaymsg input type:keyboard xkb_layout "$(localectl status | sed -n "s/^\s*X11 Layout:\s*//p")"'
      exec ${setXftDpiSway}
    '';

    minima.scrollConfigFile = pkgs.writeText "scroll-config" ''
      ${swayConfText}

      ${builtins.readFile ./config/scroll/config.d/keybinds}
      ${builtins.readFile ./config/scroll/config.d/workspace}
      ${builtins.readFile ./config/scroll/config.d/application-behavior}
      ${builtins.readFile ./config/scroll/config.d/env}
      ${builtins.readFile ./config/scroll/config.d/input}
      ${builtins.readFile ./config/scroll/config.d/application-style}
      set $terminal ${cfg.programs.terminal.name}

      ${autostart}
      exec_always --no-startup-id sh -c 'scrollmsg input type:keyboard xkb_layout "$(localectl status | sed -n "s/^\s*X11 Layout:\s*//p")"'
      exec ${setXftDpiScroll}
    '';

    minima.quickshellStoreDir = quickshellStoreDir;
  };
}
