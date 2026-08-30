{ layout, pkgs }:
let
  isHy3 = layout == "hy3";

  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  magick = "${pkgs.imagemagick}/bin/magick";
  wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
  swappy = "${pkgs.swappy}/bin/swappy";

  shotClip = ''${grim} -g "$(${slurp} -o -d)" - | ${magick} - -shave 1x1 PNG:- | ${wlCopy}'';
  shotClipFull = ''${grim} - | ${wlCopy}'';
  shotEdit = ''${grim} -g "$(${slurp} -o -d)" - | ${magick} - -shave 1x1 PNG:- | ${swappy} -f -'';
  shotEditFull = ''${grim} - | ${swappy} -f -'';

  killBinds = if isHy3 then ''
    if hy3 ~= nil then
      hl.bind(mod .. " + q", hy3.kill_active())
    else
      hl.bind(mod .. " + q", hl.dsp.window.close())
    end
  '' else ''
    hl.bind(mod .. " + q", hl.dsp.window.close())
  '';

  focusBinds = if isHy3 then ''
    if hy3 ~= nil then
      hl.bind(mod .. " + h", hy3.move_focus("l"))
      hl.bind(mod .. " + l", hy3.move_focus("r"))
      hl.bind(mod .. " + k", hy3.move_focus("u"))
      hl.bind(mod .. " + j", hy3.move_focus("d"))
    else
      hl.bind(mod .. " + h", hl.dsp.focus({ direction = "left" }))
      hl.bind(mod .. " + l", hl.dsp.focus({ direction = "right" }))
      hl.bind(mod .. " + k", hl.dsp.focus({ direction = "up" }))
      hl.bind(mod .. " + j", hl.dsp.focus({ direction = "down" }))
    end
  '' else ''
    hl.bind(mod .. " + h", hl.dsp.focus({ direction = "left" }))
    hl.bind(mod .. " + l", hl.dsp.focus({ direction = "right" }))
    hl.bind(mod .. " + k", hl.dsp.focus({ direction = "up" }))
    hl.bind(mod .. " + j", hl.dsp.focus({ direction = "down" }))
  '';

  moveBinds = if isHy3 then ''
    if hy3 ~= nil then
      hl.bind(mod .. " + CTRL + h", hy3.move_window("l"))
      hl.bind(mod .. " + CTRL + l", hy3.move_window("r"))
      hl.bind(mod .. " + CTRL + k", hy3.move_window("u"))
      hl.bind(mod .. " + CTRL + j", hy3.move_window("d"))
    else
      hl.bind(mod .. " + CTRL + h", hl.dsp.window.move({ direction = "left" }))
      hl.bind(mod .. " + CTRL + l", hl.dsp.window.move({ direction = "right" }))
      hl.bind(mod .. " + CTRL + k", hl.dsp.window.move({ direction = "up" }))
      hl.bind(mod .. " + CTRL + j", hl.dsp.window.move({ direction = "down" }))
    end
  '' else ''
    hl.bind(mod .. " + CTRL + h", hl.dsp.window.move({ direction = "left" }))
    hl.bind(mod .. " + CTRL + l", hl.dsp.window.move({ direction = "right" }))
    hl.bind(mod .. " + CTRL + k", hl.dsp.window.move({ direction = "up" }))
    hl.bind(mod .. " + CTRL + j", hl.dsp.window.move({ direction = "down" }))
  '';

  layoutBinds =
    if layout == "dwindle" then ''
      -- Layout & splitting
      hl.bind(mod .. " + a", hl.dsp.layout("togglesplit"))
      hl.bind(mod .. " + ALT + j", hl.dsp.layout("preselect d"))
      hl.bind(mod .. " + ALT + k", hl.dsp.layout("preselect r"))
      hl.bind(mod .. " + ALT + l", hl.dsp.group.toggle())
    ''
    else if layout == "master" then ''
      -- Layout
      hl.bind(mod .. " + a", hl.dsp.layout("orientationnext"))
      hl.bind(mod .. " + ALT + l", hl.dsp.group.toggle())
    ''
    else if layout == "scrolling" then ''
      -- Layout
      hl.bind(mod .. " + ALT + l", hl.dsp.layout("colresize 1.0"))
      hl.bind(mod .. " + ALT + h", hl.dsp.layout("colresize 0.5"))
      hl.bind(mod .. " + ALT + j", hl.dsp.layout("consume_or_expel prev"))
      hl.bind(mod .. " + ALT + k", hl.dsp.layout("consume_or_expel next"))
    ''
    else if layout == "monocle" then ''
      -- Layout
      hl.bind(mod .. " + ALT + l", hl.dsp.group.toggle())
    ''
    else ''
      -- Layout & splitting (i3 style)
      if hy3 ~= nil then
        hl.bind(mod .. " + a", hy3.change_group("opposite"))
        hl.bind(mod .. " + ALT + j", hy3.make_group("v"))
        hl.bind(mod .. " + ALT + k", hy3.make_group("h"))
        hl.bind(mod .. " + ALT + h", hy3.change_group("v"))
        hl.bind(mod .. " + ALT + l", hy3.change_group("tab"))
        hl.bind(mod .. " + Escape", hy3.change_group("untab"))
        hl.bind(mod .. " + CTRL + a", hy3.change_focus("lower"))
        hl.bind(mod .. " + SHIFT + a", hy3.change_focus("raise"))
      end
    '';

  scratchpadBinds = if isHy3 then ''
    if hy3 ~= nil then
      hl.bind(mod .. " + SHIFT + minus", hy3.move_to_workspace("special:scratchpad"))
    else
      hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratchpad" }))
    end
    hl.bind(mod .. " + minus", hl.dsp.workspace.toggle_special("scratchpad"))
  '' else ''
    hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratchpad" }))
    hl.bind(mod .. " + minus", hl.dsp.workspace.toggle_special("scratchpad"))
  '';
in ''
  -- Main binds
  hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
  hl.bind(mod .. " + b", hl.dsp.exec_cmd(browser))
  hl.bind(mod .. " + e", hl.dsp.exec_cmd(fileManager))
  ${killBinds}
  hl.bind(mod .. " + space", hl.dsp.window.float({ action = "toggle" }))
  hl.bind(mod .. " + f", hl.dsp.window.fullscreen())
  hl.bind(mod .. " + SHIFT + s", hl.dsp.window.pin())
  hl.bind(mod .. " + ALT + Delete", hl.dsp.exec_cmd("hyprlock"))
  hl.bind(mod .. " + SHIFT + c", hl.dsp.exec_cmd("hyprctl reload"))
  hl.bind(mod .. " + v", hl.dsp.exec_cmd("qs -c " .. qs_path .. " ipc call clipboard open"))
  hl.bind(mod .. " + d", hl.dsp.exec_cmd("qs -c " .. qs_path .. " ipc call launcher open"))

  -- Screenshots
  hl.bind("Print", hl.dsp.exec_cmd('${shotClip}'))
  hl.bind("SHIFT + Print", hl.dsp.exec_cmd('${shotClipFull}'))
  hl.bind(mod .. " + Print", hl.dsp.exec_cmd('${shotEdit}'))
  hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd('${shotEditFull}'))

  -- Focus movement
  ${focusBinds}

  -- Move windows
  ${moveBinds}

  -- Resize windows
  hl.bind(mod .. " + SHIFT + h", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
  hl.bind(mod .. " + SHIFT + l", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
  hl.bind(mod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
  hl.bind(mod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

  ${layoutBinds}

  -- Scratchpad
  ${scratchpadBinds}

  -- Logout
  hl.bind("XF86PowerOff", hl.dsp.exec_cmd("qs -c " .. qs_path .. " ipc call minimaHome open"))

  -- Multimedia keys
  hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
  hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
  hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
  hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
  hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { repeating = true })
  hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { repeating = true })

  -- Media player controls
  hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
  hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
  hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
  hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

  -- Mouse bindings
  hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
  hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
  hl.bind(mod .. " + mouse:274", hl.dsp.window.close(), { mouse = true })
''
