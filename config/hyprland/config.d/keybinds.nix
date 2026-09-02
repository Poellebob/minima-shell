{
  lib,
  pkgs,
  layout,
}:
let
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  magick = "${pkgs.imagemagick}/bin/magick";
  swappy = "${pkgs.swappy}/bin/swappy";
  wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
in
''
  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      local hy3 = hl.plugin.hy3
      hl.bind(mainMod .. " + Q", hy3.kill_active())
    end
  ''}
  ${lib.optionalString (layout != "hy3") ''
    hl.bind(mainMod .. " + Q", hl.dsp.window.close())
  ''}
  hl.bind(mainMod .. " + SPACE", hl.dsp.window.float())
  hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
  hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.pin())
  hl.bind(mainMod .. " + ALT + DELETE", hl.dsp.exec_cmd("swaylock"))
  hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
  hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("qs -c " .. qsPath .. " ipc call clipboard open"))
  hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("qs -c " .. qsPath .. " ipc call launcher open"))

  hl.bind("PRINT", hl.dsp.exec_cmd("${grim} -g \"$(${slurp} -o -d)\" - | ${magick} - -shave 1x1 PNG:- | ${wlCopy}"))
  hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("${grim} - | ${wlCopy}"))
  hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("${grim} -g \"$(${slurp} -o -d)\" - | ${swappy} -f -"))
  hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("${grim} - | ${swappy} -f -"))

  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      local hy3 = hl.plugin.hy3
      -- NOTE: no `visible = true` here — that flag restricts movement to
      -- currently-rendered nodes only, which is what was blocking focus
      -- movement into/through tab groups.
      hl.bind(mainMod .. " + H", hy3.move_focus("left"))
      hl.bind(mainMod .. " + L", hy3.move_focus("right"))
      hl.bind(mainMod .. " + K", hy3.move_focus("up"))
      hl.bind(mainMod .. " + J", hy3.move_focus("down"))
    end
  ''}
  ${lib.optionalString (layout != "hy3") ''
    hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
    hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
    hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
  ''}

  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      hl.bind(mainMod .. " + CTRL + H", hl.plugin.hy3.move_window("left"))
      hl.bind(mainMod .. " + CTRL + L", hl.plugin.hy3.move_window("right"))
      hl.bind(mainMod .. " + CTRL + K", hl.plugin.hy3.move_window("up"))
      hl.bind(mainMod .. " + CTRL + J", hl.plugin.hy3.move_window("down"))
    end
  ''}
  ${lib.optionalString (layout != "hy3") ''
    hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ direction = "left" }))
    hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ direction = "right" }))
    hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "up" }))
    hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "down" }))
  ''}

  hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
  hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
  hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
  hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

  ${lib.optionalString (layout == "dwindle") ''
    hl.bind(mainMod .. " + A", hl.dsp.layout("togglesplit"))
  ''}

  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      local hy3 = hl.plugin.hy3
      hl.bind(mainMod .. " + A", hy3.make_group("opposite", { toggle = true }))
      hl.bind(mainMod .. " + ALT + J", hy3.make_group("v"))
      hl.bind(mainMod .. " + ALT + K", hy3.make_group("h"))
      -- hy3 has no separate "stacked" layout like sway — tab groups are
      -- the only grouping mode, so both the old sway "stack" and
      -- "tabbed" binds map to the same toggletab action.
      hl.bind(mainMod .. " + ALT + H", hy3.change_group("toggletab"))
      hl.bind(mainMod .. " + ALT + L", hy3.change_group("toggletab"))
      hl.bind(mainMod .. " + ESCAPE", hy3.change_group("untab"))
      -- "raise" = ascend to parent (mirrors sway's focus parent)
      -- "lower" = descend into child (mirrors sway's focus child)
      hl.bind(mainMod .. " + CTRL + A", hy3.change_focus("lower"))
      hl.bind(mainMod .. " + SHIFT + A", hy3.change_focus("raise"))
      hl.bind(mainMod .. " + TAB", hy3.focus_tab({ direction = "right", wrap = true }))
      hl.bind(mainMod .. " + SHIFT + TAB", hy3.focus_tab({ direction = "left", wrap = true }))
      hl.bind(mainMod .. " + SHIFT + E", hy3.equalize())
      hl.bind(mainMod .. " + EQUAL", hy3.expand("expand"))
      hl.bind(mainMod .. " + SHIFT + EQUAL", hy3.expand("shrink"))
      hl.bind(mainMod .. " + 0", hy3.expand("base"))
    end
  ''}

  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      local hy3 = hl.plugin.hy3
      hl.bind(mainMod .. " + SHIFT + MINUS", hy3.move_to_workspace("special:scratchpad"))
    end
  ''}
  ${lib.optionalString (layout != "hy3") ''
    hl.bind(mainMod .. " + SHIFT + MINUS", hl.dsp.window.move({ workspace = "special:scratchpad" }))
  ''}
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

  for i = 1, 10 do
      local key = i % 10
      hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
      hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
  end

  hl.bind(mainMod .. " + CTRL + RIGHT", hl.dsp.focus({ workspace = "e+1" }))
  hl.bind(mainMod .. " + CTRL + LEFT", hl.dsp.focus({ workspace = "e-1" }))

  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      local hy3 = hl.plugin.hy3
      hl.bind(mainMod .. " + mouse:274", hy3.kill_active(), { mouse = true })
    end
  ''}
  ${lib.optionalString (layout != "hy3") ''
    hl.bind(mainMod .. " + mouse:274", hl.dsp.window.close(), { mouse = true })
  ''}
''
