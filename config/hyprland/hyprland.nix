{
  cfg,
  pkgs,
  lib,
  quickshellStoreDir,
}:

with lib;
let
  luaStr = s: "\"" + lib.escape [ "\\" "\"" ] s + "\"";

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
    concatStringsSep " .. \" + \" .. " (map (b:
      if commonToHypr ? ${b} then commonToHypr.${b}
      else luaStr b
    ) binds);

  hyprKeybind =
    kb:
    if kb.raw then
      "hl.bind(${hyprBindExpr kb.bind}, ${kb.exec})"
    else
      "hl.bind(${hyprBindExpr kb.bind}, hl.dsp.exec_cmd(${luaStr kb.exec}))";

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

  primaryDisplays = filter (n: cfg.displays.${n}.primary) (attrNames cfg.displays);
  primaryDisplayName = if primaryDisplays != [] then head primaryDisplays else null;
in
''
  local qsPath = ${luaStr "${quickshellStoreDir}"}

  local function setXftDpi(monitorName)
    if monitorName == nil or monitorName == "" then
      local mons = hl.get_monitors()
      if #mons == 0 then
        error("setXftDpi: No monitors detected.")
      end
      monitorName = mons[1].name
    end

    local mon = hl.get_monitor(monitorName)
    if mon == nil then
      return false
    end

    local scale = tonumber(mon.scale) or 1.0

    -- The +0.5 is to always round the float instead of flooring it.
    local dpi = math.floor(96 * scale + 0.5)
    hl.exec_cmd("notify-send dpi " .. dpi)

    hl.exec_cmd("printf 'Xft.dpi: %d\\n' " .. dpi .. " | xrdb -merge")
    return true
  end

  local function setXftDpiWhenReady(monitorName, attempts)
    if setXftDpi(monitorName) then
      return
    end
    if attempts <= 0 then
      return
    end
    hl.timer(function()
      setXftDpiWhenReady(monitorName, attempts - 1)
    end, { timeout = 500, type = "oneshot" })
  end

  ${concatStringsSep "\n" (mapAttrsToList hyprMonitor cfg.displays)}

  ${concatStringsSep "\n" (concatMap (n: hyprWorkspaceRules n cfg.displays.${n}) (attrNames (filterAttrs (n: v: (v.workspace != null || v.workspaces != null)) cfg.displays)))}

  ${builtins.readFile ./config.d/colors.lua}

  ${builtins.readFile ./config.d/animations.lua}

  ${import ./config.d/decorations.nix}

  ${import ./config.d/layout.nix {
    layout = cfg.hyprland.layout;
  }}

  ${import ./config.d/window-rules.nix}

  ${import ./config.d/gestures.nix}

  ${import ./config.d/input.nix}

  ${import ./config.d/misc.nix}

  ${import ./config.d/keybinds.nix {
    inherit lib pkgs;
    layout = cfg.hyprland.layout;
    modifier = luaStr cfg.hyprland.modifier;
  }}

  ${concatStringsSep "\n" (map hyprKeybind (filter (kb: kb.bind != [ ]) cfg.keybinds))}

  ${concatStringsSep "\n" (mapAttrsToList hyprSpecialWs cfg.specialWorkspaces)}

  hl.on("hyprland.start", function()
    ${optionalString (primaryDisplayName != null) ''
    hl.dsp.focus({monitor = ${luaStr primaryDisplayName}})
    setXftDpiWhenReady(${luaStr primaryDisplayName}, 20)
    ''}
    hl.exec_cmd(${luaStr (dropCaps "${pkgs.quickshell}/bin/qs -c ${quickshellStoreDir}")})
    hl.exec_cmd(${luaStr "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"})
    hl.exec_cmd(${luaStr "${pkgs.awww}/bin/awww-daemon"})
    hl.exec_cmd(${luaStr "systemctl --user import-environment GTK_THEME QT_QPA_PLATFORMTHEME"})
    hl.exec_cmd(${luaStr "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme Breeze-Dark"})
    hl.exec_cmd(${luaStr "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store"})

    ${concatStringsSep "\n    " (map (a: "hl.exec_cmd(${luaStr (dropCaps a)})") cfg.autostart)}
    ${concatStringsSep "\n    " specialWorkspaceAutostarts}
  end)

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
