{
  cfg,
  pkgs,
  lib,
  quickshellStoreDir,
  setXftDpi,
}:

with lib;
let
  luaStr = s: "\"" + lib.escape [ "\\" "\"" ] s + "\"";

  colorsJson = builtins.fromJSON (builtins.readFile ../../colors.json);
  colors = colorsJson.colors.${if cfg.minimaConfig.darkTheme then "dark" else "light"};

  mainMod = cfg.hyprland.modifier;

  monitorMode = d: if d.hz != null && hasInfix "x" d.res then "${d.res}@${toString d.hz}" else d.res;

  hyprMonitor = name: d: ''
    hl.monitor({
        output = ${luaStr (if name == "*" then "" else name)},
        mode = ${luaStr (monitorMode d)},
        position = ${luaStr "${toString d.position.x}x${toString d.position.y}"},
        scale = ${toString d.scale},
    })
  '';

  hyprWorkspaceRule =
    name: d:
    optionalString (d.workspace != null) ''
      hl.workspace_rule({
          workspace = ${luaStr (toString d.workspace)},
          monitor = ${luaStr name},
          default = true,
      })
    '';

  matchKey =
    k:
    if k == "app_id" || k == "class" then
      "class"
    else if k == "title" then
      "title"
    else
      k;

  hyprSpecialWs =
    name: ws:
    concatStringsSep "\n" (
      [
        "hl.bind(${luaStr (mainMod + " + " + ws.key)}, hl.dsp.workspace.toggle_special(${luaStr name}))"
      ]
      ++ mapAttrsToList (k: vs: ''
        hl.window_rule({
            match = { ${matchKey k} = ${luaStr (concatStringsSep "|" vs)} },
            workspace = ${luaStr "special:${name} silent"},
        })
      '') ws.rule
    );

  specialWorkspaceAutostarts = mapAttrsToList (
    name: ws:
    optionalString (ws.autostart && ws.startCommand != "") "hl.exec_cmd(${luaStr ws.startCommand})"
  ) cfg.specialWorkspaces;
in
''
  local mainMod = ${luaStr mainMod}
  local terminal = ${luaStr cfg.programs.terminal.name}
  local fileManager = ${luaStr cfg.programs.fileManager.name}
  local browser = ${luaStr cfg.programs.browser.name}
  local qsPath = ${luaStr "${quickshellStoreDir}"}

  ${concatStringsSep "\n" (mapAttrsToList hyprMonitor cfg.displays)}

  ${concatStringsSep "\n" (filter (x: x != "") (mapAttrsToList hyprWorkspaceRule cfg.displays))}

  ${builtins.readFile ./config.d/application-style.lua}

  ${import ./config.d/decorations.nix {
    inherit lib colors;
  }}

  ${import ./config.d/application-behavior.nix {
    layout = cfg.hyprland.layout;
  }}

  ${builtins.readFile ./config.d/input.lua}

  ${import ./config.d/keybinds.nix {
    inherit lib pkgs;
    layout = cfg.hyprland.layout;
  }}

  ${builtins.readFile ./config.d/workspace.lua}

  ${concatStringsSep "\n" (mapAttrsToList hyprSpecialWs cfg.specialWorkspaces)}

  hl.on("hyprland.start", function()
      ${concatStringsSep "\n    " (map (a: "hl.exec_cmd(${luaStr a})") cfg.autostart)}
      ${concatStringsSep "\n    " specialWorkspaceAutostarts}
      hl.exec_cmd(${luaStr "${pkgs.quickshell}/bin/qs -c ${quickshellStoreDir}"})
      hl.exec_cmd(${luaStr "${setXftDpi}"})
      hl.exec_cmd(${luaStr "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"})
      hl.exec_cmd(${luaStr "${pkgs.awww}/bin/awww-daemon"})
      hl.exec_cmd(${luaStr "systemctl --user import-environment GTK_THEME QT_QPA_PLATFORMTHEME"})
      hl.exec_cmd(${luaStr "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme Breeze-Dark"})
      hl.exec_cmd(${luaStr "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store"})
  end)

  local _kbLayoutHandle = io.popen("localectl status | sed -n 's/^[[:space:]]*X11 Layout:[[:space:]]*//p'")
  local kbLayout = _kbLayoutHandle:read("*l")
  _kbLayoutHandle:close()
  if kbLayout ~= nil and kbLayout ~= "" then
    hl.config({ input = { kb_layout = kbLayout } })
  end

  ${cfg.hyprland.extraLua}
''
