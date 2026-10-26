{
  cfg,
  pkgs,
  lib,
}:

with lib;
let
  # Stable QuickShell config name; session.nix symlinks it to the config
  # derivation so keybinds survive rebuilds.
  qsConfigName = cfg.quickshellConfigName;
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

  commonToSway = modifier: {
    "Main" = modifier;
    "Shift" = "Shift";
    "Ctrl" = "Control";
    "Alt" = "Mod1";
  };

  swayBindExpr = modifier: binds:
    concatStringsSep "+" (map (b:
      if commonToSway modifier ? ${b} then (commonToSway modifier).${b}
      else b
    ) binds);

  swayKeybind =
    modifier: kb:
    if kb.raw then
      ''
        ${kb.type} ${swayBindExpr modifier kb.bind} ${kb.exec}
      ''
    else
      ''
        ${kb.type} ${swayBindExpr modifier kb.bind} exec ${kb.exec}
      '';

  swayDefaultBind = modifier: binds: action:
    optionalString (cfg.keybinds.enable && binds != [ ]) "bindsym ${swayBindExpr modifier binds} ${action}";

  swaySpecialWs =
    modifier: wm: name: ws:
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
      ${optionalString (ws.keybind != [ ]) "bindsym ${swayBindExpr modifier ws.keybind} [workspace=$ws_${name}] move workspace to output current, workspace $ws_${name}"}
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

  expandWorkspace = d:
    let
      wsList = if d.workspaces != null then d.workspaces
               else if d.workspace != null then [ d.workspace ]
               else [];
      expandRange = item:
        if builtins.isInt item then [ (toString item) ]
        else let
          parts = builtins.split "-" (toString item);
          start = toInt (builtins.head parts);
          end = toInt (builtins.head (builtins.tail (builtins.tail parts)));
        in map toString (range start end);
    in concatMap expandRange wsList;

  swayConfText = wm:
    let
      modifier = if wm == "scroll" then cfg.scroll.modifier else cfg.sway.modifier;
    in ''
    set $qs_config ${qsConfigName}

    ${concatMapStringsSep "\n" (x: swayOutputBlock x.name x.value) (
      mapAttrsToList (n: v: {
        name = n;
        value = v;
      }) cfg.displays
    )}

    ${concatMapStringsSep "\n" (x: "workspace ${x.ws} output ${x.name}") (
      concatMap (n:
        map (ws: { name = n; ws = ws; }) (expandWorkspace cfg.displays.${n})
      ) (attrNames (filterAttrs (n: v: (v.workspace != null || v.workspaces != null)) cfg.displays))
    )}

    ${concatMapStringsSep "\n" (a: "exec ${a}") cfg.autostart}

    ${concatStringsSep "\n" (map (swayKeybind modifier) (filter (kb: kb.bind != [ ]) cfg.keybinds.custom))}

    ${concatMapStringsSep "\n" (x: swaySpecialWs modifier wm x.name x.value) (
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

   ${import ./config.d/keybinds.nix {
     inherit wm pkgs;
     modifier = if wm == "scroll" then cfg.scroll.modifier else cfg.sway.modifier;
     keybinds = cfg.keybinds;
     terminalEnabled = cfg.terminal.enable;
     bind = swayDefaultBind (if wm == "scroll" then cfg.scroll.modifier else cfg.sway.modifier);
     bindExpr = swayBindExpr (if wm == "scroll" then cfg.scroll.modifier else cfg.sway.modifier);
   }}
   ${import ./config.d/workspace.nix {
     modifier = if wm == "scroll" then cfg.scroll.modifier else cfg.sway.modifier;
   }}
  ${import ./config.d/application-behavior.nix { inherit wm; }}
  ${builtins.readFile ./config.d/env}
  ${builtins.readFile ./config.d/input}
  ${import ./config.d/application-style.nix { inherit wm; }}

  # Session vars for the systemd units. SWAYSOCK too: the units are not bound
  # to graphical-session.target (it is already active here and would start
  # them before the compositor's IPC socket exists), so the compositor starts
  # them itself, chained after the import to pick up the fresh SWAYSOCK.
  exec dbus-update-activation-environment --systemd SWAYSOCK WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_ID GTK_THEME QT_QPA_PLATFORMTHEME${optionalString cfg.session.systemd.enable " && systemctl --user restart minima-shell.service minima-wallpaper.service minima-cliphist.service"}
  ${optionalString cfg.session.systemd.enable ''
    exec_always --no-startup-id systemctl --user start minima-session.target
  ''}
  exec ${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1
  ${optionalString (!cfg.session.systemd.enable) ''
    exec awww-daemon
    exec ${pkgs.quickshell}/bin/qs -c $qs_config
    exec wl-paste --watch cliphist store
  ''}

  exec_always --no-startup-id sh -c '${msgCmd} input type:keyboard xkb_layout "$(localectl status | sed -n "s/^\s*X11 Layout:\s*//p")"'

  ${extraConfig}

  # minima: runtime monitor overrides (managed by the shell).
  # Included last so its output blocks win over the declarative ones above.
  include ~/.config/minima/monitors-sway.conf
''
