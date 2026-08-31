{ cfg, pkgs, lib, quickshellStoreDir, setXftDpi }:

with lib;
let
  luaStr = s: "\"" + lib.escape [ "\\" "\"" ] s + "\"";

  mainMod = cfg.hyprland.modifier;

  monitorMode = d:
    if d.hz != null && hasInfix "x" d.res
    then "${d.res}@${toString d.hz}"
    else d.res;

  hyprMonitor = name: d: ''
    hl.monitor({
      output = ${luaStr (if name == "*" then "" else name)},
      mode = ${luaStr (monitorMode d)},
      position = ${luaStr "${toString d.position.x}x${toString d.position.y}"},
      scale = ${toString d.scale},
    })
  '';

  hyprWorkspaceRule = name: d:
    optionalString (d.workspace != null) ''
      hl.workspace_rule({
        workspace = ${luaStr (toString d.workspace)},
        monitor = ${luaStr name},
        default = true,
      })
    '';

  matchKey = k:
    if k == "app_id" || k == "class" then "class"
    else if k == "title" then "title"
    else k;

  hyprSpecialWs = name: ws:
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

  screenshotCopy = removeSuffix "\n" ''
    ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -o -d)\" - | ${pkgs.imagemagick}/bin/magick - -shave 1x1 PNG:- | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  screenshotEdit = removeSuffix "\n" ''
    ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -o -d)\" - | ${pkgs.swappy}/bin/swappy -f -
  '';

  layoutConfig = {
    dwindle = ''
      hl.config({
        dwindle = {
          preserve_split = true,
        },
      })
    '';
    master = ''
      hl.config({
        master = {
          new_status = "master",
        },
      })
    '';
    scrolling = ''
      hl.config({
        scrolling = {
          fullscreen_on_one_column = true,
        },
      })
    '';
  }.${cfg.hyprland.layout};

  startCmds =
    map (a: "hl.exec_cmd(${luaStr a})") cfg.autostart
    ++ mapAttrsToList (name: ws: optionalString (ws.autostart && ws.startCommand != "") "hl.exec_cmd(${luaStr ws.startCommand})") cfg.specialWorkspaces
    ++ [
      "hl.exec_cmd(${luaStr "${pkgs.quickshell}/bin/qs -c ${quickshellStoreDir}"})"
      "hl.exec_cmd(${luaStr "${setXftDpi}"})"
      "hl.exec_cmd(${luaStr "awww-daemon"})"
      "hl.exec_cmd(${luaStr "systemctl --user import-environment GTK_THEME QT_QPA_PLATFORMTHEME"})"
      "hl.exec_cmd(${luaStr "gsettings set org.gnome.desktop.interface gtk-theme Breeze-Dark"})"
      "hl.exec_cmd(${luaStr "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"})"
      "hl.exec_cmd(${luaStr "wl-paste --watch cliphist store"})"
      "hl.exec_cmd(\"hyprctl eval \\\"hl.config({ input = { kb_layout = \\\"$(localectl status | sed -n 's/^[[:space:]]*X11 Layout:[[:space:]]*//p')\\\" } })\\\"\")"
    ];
in
''
  local mainMod = ${luaStr mainMod}
  local terminal = ${luaStr cfg.programs.terminal.name}
  local fileManager = ${luaStr cfg.programs.fileManager.name}
  local browser = ${luaStr cfg.programs.browser.name}
  local qsPath = ${luaStr "${quickshellStoreDir}"}

  ${concatStringsSep "\n" (mapAttrsToList hyprMonitor cfg.displays)}

  ${concatStringsSep "\n" (filter (x: x != "") (mapAttrsToList hyprWorkspaceRule cfg.displays))}

  hl.config({
    general = {
      gaps_in = 3,
      gaps_out = 3,
      border_size = 2,
      layout = ${luaStr cfg.hyprland.layout},
    },
  })

  ${layoutConfig}

  hl.config({
    input = {
      touchpad = {
        natural_scroll = true,
        tap_to_click = true,
        clickfinger_behavior = true,
        disable_while_typing = true,
      },
    },
  })

  hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
  hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
  hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
  hl.bind(mainMod .. " + Q", hl.dsp.window.close())
  hl.bind(mainMod .. " + SPACE", hl.dsp.window.float())
  hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
  hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.pin())
  hl.bind(mainMod .. " + ALT + DELETE", hl.dsp.exec_cmd("swaylock"))
  hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
  hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("qs -c " .. qsPath .. " ipc call clipboard open"))
  hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("qs -c " .. qsPath .. " ipc call launcher open"))

  hl.bind("PRINT", hl.dsp.exec_cmd("${screenshotCopy}"))
  hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy"))
  hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("${screenshotEdit}"))
  hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("${pkgs.grim}/bin/grim - | ${pkgs.swappy}/bin/swappy -f -"))

  hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
  hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
  hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
  hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

  hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ direction = "left" }))
  hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ direction = "right" }))
  hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "up" }))
  hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "down" }))

  hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
  hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
  hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
  hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

  ${optionalString (cfg.hyprland.layout == "dwindle") ''
    hl.bind(mainMod .. " + A", hl.dsp.layout("togglesplit"))
  ''}

  hl.bind(mainMod .. " + SHIFT + MINUS", hl.dsp.window.move({ workspace = "special:scratchpad" }))
  hl.bind(mainMod .. " + MINUS", hl.dsp.workspace.toggle_special("scratchpad"))

  hl.bind("XF86PowerOff", hl.dsp.exec_cmd("qs -c " .. qsPath .. " ipc call minimaLogout open"))

  hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
  hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
  hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
  hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
  hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"))
  hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"))

  hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
  hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
  hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
  hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
  hl.bind(mainMod .. " + mouse:274", hl.dsp.window.close(), { mouse = true })

  for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
  end

  hl.bind(mainMod .. " + CTRL + RIGHT", hl.dsp.focus({ workspace = "e+1" }))
  hl.bind(mainMod .. " + CTRL + LEFT", hl.dsp.focus({ workspace = "e-1" }))

  ${concatStringsSep "\n" (mapAttrsToList hyprSpecialWs cfg.specialWorkspaces)}

  hl.window_rule({
    match = { class = ${luaStr "nmtui|bluedevil-wizard"} },
    float = true,
  })

  hl.window_rule({
    match = { class = ${luaStr "vrmonitor"} },
    float = true,
  })

  hl.window_rule({
    match = { title = ${luaStr "SteamVR.*"} },
    float = true,
  })

  hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
    border_size = 0,
  })

  hl.on("hyprland.start", function()
    ${concatStringsSep "\n    " startCmds}
  end)

  ${cfg.hyprland.extraLua}
''
