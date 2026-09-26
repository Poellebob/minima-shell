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

  # systemd-managed daemons (session.nix) are exec'd from here only when
  # session.systemd.enable is false.
  startupLua = ''
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

  local function setXftDpi(monitorName)
    local mon = hl.get_monitor(monitorName)
    if mon == nil then
      local mons = hl.get_monitors()
      if #mons == 0 then
        return false
      end
      mon = mons[1]
    end

    local scale = tonumber(mon.scale) or 1.0

    -- The +0.5 is to always round the float instead of flooring it.
    local dpi = math.floor(96 * scale + 0.5)
    hl.exec_cmd("printf 'Xft.dpi: %d\\n' " .. dpi .. " | xrdb -merge")
    return true
  end

  local function getCursorPos()
    local h = io.popen("hyprctl cursorpos 2>/dev/null")
    local out = h:read("*a")
    h:close()
    return tonumber(out:match("^%s*(%-?%d+)")), tonumber(out:match(",%s*(%-?%d+)"))
  end

  -- Geometry comes from hyprctl (layout coordinates, same space as cursorpos).
  -- hl.get_monitor() alone is not enough: a monitor that exists but has not
  -- rendered its first frame yet silently drops focus/cursor dispatches, so
  -- success is only declared once the cursor is actually inside the monitor.
  local function monitorRect(name)
    local h = io.popen("hyprctl monitors -j 2>/dev/null")
    local json = h:read("*a")
    h:close()
    local idx = json:find('"name":"' .. name .. '"', nil, true)
    if idx == nil then
      return nil
    end
    local block = json:sub(idx, math.min(#json, idx + 4096))
    local x = tonumber(block:match('"x":%s*(%-?%d+)'))
    local y = tonumber(block:match('"y":%s*(%-?%d+)'))
    local w = tonumber(block:match('"width":%s*(%d+)'))
    local hgt = tonumber(block:match('"height":%s*(%d+)'))
    if x == nil or y == nil or w == nil or hgt == nil or w == 0 or hgt == 0 then
      return nil
    end
    return x, y, w, hgt
  end

  local function placeCursorOnMonitor(name)
    local x, y, w, hgt = monitorRect(name)
    if x == nil then
      return false
    end

    local cx, cy = getCursorPos()
    if cx ~= nil and cy ~= nil
      and cx >= x and cx < x + w
      and cy >= y and cy < y + hgt then
      return true
    end

    hl.exec_cmd("hyprctl dispatch movecursor "
      .. tostring(math.floor(x + w / 2)) .. " " .. tostring(math.floor(y + hgt / 2)))
    return false
  end

  local function activatePrimaryWhenReady(monitorName, attempts)
    -- DPI is independent of cursor placement: fall back to the first monitor
    -- when the primary is missing or not ready.
    setXftDpi(monitorName)

    local done = true
    if monitorName ~= nil and monitorName ~= "" then
      local mon = hl.get_monitor(monitorName)
      if mon == nil then
        done = false
      else
        hl.dsp.focus({ monitor = monitorName })
        done = placeCursorOnMonitor(monitorName)
      end
    end

    if done or attempts <= 0 then
      return
    end
    hl.timer(function()
      activatePrimaryWhenReady(monitorName, attempts - 1)
    end, { timeout = 500, type = "oneshot" })
  end

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
    activatePrimaryWhenReady(${
      if primaryDisplayName != null then luaStr primaryDisplayName else "nil"
    }, 40)

    ${startupLua}
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
