{
  cfg,
  pkgs,
  lib,
  quickshellStoreDir,
}:

with lib;
let
  swayOutputBlock =
    name: d:
    let
      outputName = if name == "" then "*" else name;
    in
    ''
      output ${outputName} {
        res ${d.res}
        position ${toString d.position.x} ${toString d.position.y}
        scale ${toString d.scale}
      }'';

  swayBindExpr = binds: concatStringsSep "+" (map (b: if b == "mainMod" then "$mod" else b) binds);

  swayKeybind =
    kb:
    if kb.raw then
      ''
        ${kb.type} ${swayBindExpr kb.bind} ${kb.exec}
      ''
    else
      ''
        ${kb.type} ${swayBindExpr kb.bind} exec ${kb.exec}
      '';

  swaySpecialWs =
    wm: name: ws:
    let
      ruleStrings = lib.mapAttrsToList (k: vs: ''${k}="${lib.concatStringsSep "|" vs}"'') ws.rule;
      assigns = lib.concatMapStringsSep "\n      " (r: "assign [${r}] workspace $ws_${name}") ruleStrings;
      setSize = lib.concatMapStringsSep "\n      " (r: "for_window [${r}] set_size w 1.0") ruleStrings;
    in
    ''
      set $ws_${name} "${name}"
      ${optionalString ws.autostart "exec ${ws.startCommand}"}
      ${assigns}
      ${optionalString (wm == "scroll") setSize}
      bindsym ${swayBindExpr ws.keybind} [workspace=$ws_${name}] move workspace to output current, workspace $ws_${name}
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

  primaryDisplay = findFirst (d: d.primary) (throw "No primary display") (attrValues cfg.displays);

  swayConfText = wm: ''
      set $mod ${cfg.sway.modifier}
    set $qs_path ${quickshellStoreDir}

    ${concatMapStringsSep "\n" (x: swayOutputBlock x.name x.value) (
      mapAttrsToList (n: v: {
        name = n;
        value = v;
      }) cfg.displays
    )}

    ${concatMapStringsSep "\n" (x: "workspace ${toString x.value.workspace} output ${x.name}") (
      mapAttrsToList (n: v: {
        name = n;
        value = v;
      }) (filterAttrs (n: v: v.workspace != null) cfg.displays)
    )}

    ${concatMapStringsSep "\n" (a: "exec ${a}") cfg.autostart}

    ${concatStringsSep "\n" (map swayKeybind (filter (kb: kb.bind != [ ]) cfg.keybinds))}

    ${concatMapStringsSep "\n" (x: swaySpecialWs wm x.name x.value) (
      mapAttrsToList (n: v: {
        name = n;
        value = v;
      }) cfg.specialWorkspaces
    )}

    ${optionalString (wm == "swayfx") swayfxConfig}
  '';
in
wm: extraConfig:
let
  msgCmd = if wm == "scroll" then "scrollmsg" else "swaymsg";
in
pkgs.writeText "${wm}-config" ''
  ${swayConfText wm}

  ${import ./config.d/keybinds.nix { inherit wm pkgs; }}
  ${builtins.readFile ./config.d/workspace}
  ${import ./config.d/application-behavior.nix { inherit wm; }}
  ${builtins.readFile ./config.d/env}
  ${builtins.readFile ./config.d/input}
  ${import ./config.d/application-style.nix { inherit wm; }}

  exec awww-daemon
  exec ${pkgs.quickshell}/bin/qs -c $qs_path
  exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
  exec ${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1
  exec wl-paste --watch cliphist store

  exec_always --no-startup-id sh -c '${msgCmd} input type:keyboard xkb_layout "$(localectl status | sed -n "s/^\s*X11 Layout:\s*//p")"'

  ${extraConfig}
''
