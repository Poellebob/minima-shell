{
  cfg,
  pkgs,
  lib,
}:

with lib;
let
  luaStr = s: "\"" + lib.escape [ "\\" "\"" ] s + "\"";

  # Stable QuickShell config name; session.nix symlinks it to the config
  # derivation so keybinds survive rebuilds.
  qsConfigName = cfg.quickshellConfigName;

  commonToHypr = {
    "Main" = luaStr cfg.hyprland.modifier;
    "Shift" = luaStr "SHIFT";
    "Ctrl" = luaStr "CTRL";
    "Alt" = luaStr "ALT";
  };

  monitorMode = d: if d.hz != null && hasInfix "x" d.res then "${d.res}@${toString d.hz}" else d.res;

  hyprMonitor = name: d: ''
    hl.monitor({
      output = ${luaStr (if name == "*" then "" else name)},
      mode = ${luaStr (monitorMode d)},
      position = ${luaStr "${toString d.position.x}x${toString d.position.y}"},
      scale = ${toString d.scale},
    })
  '';

  expandWorkspace =
    d:
    let
      wsList =
        if d.workspaces != null then
          d.workspaces
        else if d.workspace != null then
          [ d.workspace ]
        else
          [ ];
      expandRange =
        item:
        if builtins.isInt item then
          [ (toString item) ]
        else
          let
            parts = builtins.split "-" (toString item);
            start = toInt (builtins.head parts);
            end = toInt (builtins.head (builtins.tail (builtins.tail parts)));
          in
          map toString (range start end);
    in
    concatMap expandRange wsList;

  hyprWorkspaceRules =
    name: d:
    let
      defaultWs = if d.workspace != null then toString d.workspace else null;
    in
    map (ws: ''
      hl.workspace_rule({
        workspace = ${luaStr ws},
        monitor = ${luaStr name},
        default = ${if ws == defaultWs then "true" else "false"},
      })
    '') (expandWorkspace d);

  matchKey =
    k:
    if k == "app_id" || k == "class" then
      "class"
    else if k == "title" then
      "title"
    else
      k;

  hyprBindExpr =
    binds:
    concatStringsSep " .. \" + \" .. " (
      map (b: if commonToHypr ? ${b} then commonToHypr.${b} else luaStr b) binds
    );

  hyprKeybind =
    kb:
    if kb.raw then
      "hl.bind(${hyprBindExpr kb.bind}, ${kb.exec})"
    else
      "hl.bind(${hyprBindExpr kb.bind}, hl.dsp.exec_cmd(${luaStr kb.exec}))";

  hyprDefaultBind =
    binds: action:
    optionalString (cfg.keybinds.enable && binds != [ ]) "hl.bind(${hyprBindExpr binds}, ${action})";

  hyprSpecialWs =
    name: ws:
    concatStringsSep "\n" (
      [
        "hl.bind(${hyprBindExpr ws.keybind}, hl.dsp.workspace.toggle_special(${luaStr name}))"
      ]
      ++ mapAttrsToList (k: vs: ''
        hl.window_rule({
          match = { ${matchKey k} = ${luaStr (concatStringsSep "|" vs)} },
          workspace = ${luaStr "special:${name} silent"},
        })
      '') ws.rule
    );

  # NixOS launches Hyprland through a setcap wrapper that raises CAP_SYS_NICE
  # into the ambient set. Capability sets are per-thread, so Hyprland only drops
  # it on its main thread; anything spawned during config load still inherits
  # it. bwrap (steam, flatpak, ...) refuses to run with unexpected capabilities,
  # so strip the leaked caps from every process spawned at startup.
  dropCaps =
    cmd:
    "${pkgs.util-linux}/bin/setpriv --ambient-caps=-all --inh-caps=-all sh -c ${escapeShellArg cmd}";

  specialWorkspaceAutostarts = mapAttrsToList (
    name: ws:
    optionalString (
      ws.autostart && ws.startCommand != ""
    ) "hl.exec_cmd(${luaStr (dropCaps ws.startCommand)})"
  ) cfg.specialWorkspaces;

  # systemd-managed daemons (session.nix) are started from here: the units are
  # deliberately not bound to graphical-session.target, because that target is
  # already active when Hyprland comes up and the units would start before the
  # compositor's IPC socket exists. The restart is chained after the session
  # env import so the units pick up the fresh HYPRLAND_INSTANCE_SIGNATURE (a
  # plain "start" would keep a unit that is already running on a stale socket).
  systemdSessionStart = "dbus-update-activation-environment --systemd DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_ID GTK_THEME QT_QPA_PLATFORMTHEME && systemctl --user restart minima-shell.service minima-wallpaper.service minima-cliphist.service";

  # systemd-managed daemons are exec'd directly from here only when
  # session.systemd.enable is false.
  startupLua = ''
    ${optionalString cfg.session.systemd.enable ''
      hl.exec_cmd(${luaStr systemdSessionStart})
    ''}
    hl.exec_cmd(${luaStr "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"})
    hl.exec_cmd(${luaStr "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme Breeze-Dark"})
    ${optionalString (!cfg.session.systemd.enable) ''
      hl.exec_cmd(${luaStr (dropCaps "${pkgs.quickshell}/bin/qs -c ${qsConfigName}")})
      hl.exec_cmd(${luaStr "${pkgs.awww}/bin/awww-daemon"})
      hl.exec_cmd(${luaStr "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store"})
    ''}
    ${concatStringsSep "\n    " (map (a: "hl.exec_cmd(${luaStr (dropCaps a)})") cfg.autostart)}
    ${concatStringsSep "\n    " specialWorkspaceAutostarts}
  '';

  primaryDisplays = filter (n: cfg.displays.${n}.primary) (attrNames cfg.displays);
  primaryDisplayName = if primaryDisplays != [ ] then head primaryDisplays else null;
in
''
  local qsConfigName = ${luaStr qsConfigName}

  ${concatStringsSep "\n" (mapAttrsToList hyprMonitor cfg.displays)}

  ${concatStringsSep "\n" (
    concatMap (n: hyprWorkspaceRules n cfg.displays.${n}) (
      attrNames (filterAttrs (n: v: (v.workspace != null || v.workspaces != null)) cfg.displays)
    )
  )}

  ${builtins.readFile ./config.d/colors.lua}

  ${builtins.readFile ./config.d/animations.lua}

  ${import ./config.d/decorations.nix}

  ${import ./config.d/layout.nix {
    layout = cfg.hyprland.layout;
  }}

  ${import ./config.d/window-rules.nix}

  ${import ./config.d/layer-rules.nix}

  ${import ./config.d/gestures.nix}

  ${import ./config.d/input.nix}

  ${import ./config.d/misc.nix}

   ${import ./config.d/keybinds.nix {
     inherit lib pkgs;
     layout = cfg.hyprland.layout;
     keybinds = cfg.keybinds;
     terminalEnabled = cfg.terminal.enable;
     bind = hyprDefaultBind;
     mouseModifier = luaStr cfg.hyprland.modifier;
     modifier = luaStr cfg.hyprland.modifier;
   }}

   ${concatStringsSep "\n" (map hyprKeybind (filter (kb: kb.bind != [ ]) cfg.keybinds.custom))}

  ${concatStringsSep "\n" (mapAttrsToList hyprSpecialWs cfg.specialWorkspaces)}

  hl.on("hyprland.start", function()
    ${startupLua}
  end)

  ${optionalString (primaryDisplayName != null) ''
    hl.on("monitor.added", function(m)
      if m.name == ${luaStr primaryDisplayName} then
        hl.dispatch(hl.dsp.focus({ monitor = ${luaStr primaryDisplayName} }))
      end
    end)
  ''}

  local _kbLayoutHandle = io.popen("localectl status | sed -n 's/^[[:space:]]*X11 Layout:[[:space:]]*//p'")
  local kbLayout = _kbLayoutHandle:read("*l")
  _kbLayoutHandle:close()
  if kbLayout ~= nil and kbLayout ~= "" then
    hl.config({ input = { kb_layout = kbLayout } })
  end

  hl.config({
    xwayland = {
      force_zero_scaling = true
    }
  })

  ${cfg.hyprland.extraLua}
''
