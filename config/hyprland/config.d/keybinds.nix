{
  lib,
  pkgs,
  layout,
  keybinds,
  terminalEnabled,
  bind,
  mouseModifier,
  modifier,
}:
let
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  magick = "${pkgs.imagemagick}/bin/magick";
  swappy = "${pkgs.swappy}/bin/swappy";
  wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
  b = keybinds;
in
''
  ${lib.optionalString terminalEnabled (bind b.terminal "hl.dsp.exec_cmd(\"${pkgs.kitty}/bin/kitty\")")}
  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      local hy3 = hl.plugin.hy3
      ${bind b.window.close "hy3.kill_active()"}
    end
  ''}
  ${lib.optionalString (layout != "hy3") (bind b.window.close "hl.dsp.window.close()")}
  ${bind b.window.floating "hl.dsp.window.float()"}
  ${bind b.window.fullscreen "hl.dsp.window.fullscreen()"}
  ${bind b.window.sticky "hl.dsp.window.pin()"}
  ${bind b.session.lock "hl.dsp.exec_cmd(\"qs -c \" .. qsConfigName .. \" ipc call minimaLock open\")"}
  ${bind b.session.reload "hl.dsp.exec_cmd(\"hyprctl reload\")"}
  ${bind b.session.clipboard "hl.dsp.exec_cmd(\"qs -c \" .. qsConfigName .. \" ipc call clipboard open\")"}
  ${bind b.session.launcher "hl.dsp.exec_cmd(\"qs -c \" .. qsConfigName .. \" ipc call launcher open\")"}

  ${bind b.screenshot.selection "hl.dsp.exec_cmd(\"${grim} -g \\\"$(${slurp} -o -d)\\\" - | ${magick} - -shave 1x1 PNG:- | ${wlCopy}\")"}
  ${bind b.screenshot.fullscreen "hl.dsp.exec_cmd(\"${grim} - | ${wlCopy}\")"}
  ${bind b.screenshot.editSelection "hl.dsp.exec_cmd(\"${grim} -g \\\"$(${slurp} -o -d)\\\" - | ${swappy} -f -\")"}
  ${bind b.screenshot.editFullscreen "hl.dsp.exec_cmd(\"${grim} - | ${swappy} -f -\")"}

  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      local hy3 = hl.plugin.hy3
      ${bind b.focus.left "hy3.move_focus(\"left\")"}
      ${bind b.focus.right "hy3.move_focus(\"right\")"}
      ${bind b.focus.up "hy3.move_focus(\"up\")"}
      ${bind b.focus.down "hy3.move_focus(\"down\")"}
    end
  ''}
  ${lib.optionalString (layout != "hy3") ''
    ${bind b.focus.left "hl.dsp.focus({ direction = \"left\" })"}
    ${bind b.focus.right "hl.dsp.focus({ direction = \"right\" })"}
    ${bind b.focus.up "hl.dsp.focus({ direction = \"up\" })"}
    ${bind b.focus.down "hl.dsp.focus({ direction = \"down\" })"}
  ''}

  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      ${bind b.move.left "hl.plugin.hy3.move_window(\"left\", { once = true })"}
      ${bind b.move.right "hl.plugin.hy3.move_window(\"right\", { once = true })"}
      ${bind b.move.up "hl.plugin.hy3.move_window(\"up\", { once = true })"}
      ${bind b.move.down "hl.plugin.hy3.move_window(\"down\", { once = true })"}
    end
  ''}
  ${lib.optionalString (layout != "hy3") ''
    ${bind b.move.left "hl.dsp.window.move({ direction = \"left\" })"}
    ${bind b.move.right "hl.dsp.window.move({ direction = \"right\" })"}
    ${bind b.move.up "hl.dsp.window.move({ direction = \"up\" })"}
    ${bind b.move.down "hl.dsp.window.move({ direction = \"down\" })"}
  ''}

  ${bind b.resize.shrinkWidth "hl.dsp.window.resize({ x = -100, y = 0, relative = true })"}
  ${bind b.resize.growWidth "hl.dsp.window.resize({ x = 100, y = 0, relative = true })"}
  ${bind b.resize.shrinkHeight "hl.dsp.window.resize({ x = 0, y = -100, relative = true })"}
  ${bind b.resize.growHeight "hl.dsp.window.resize({ x = 0, y = 100, relative = true })"}

  ${lib.optionalString (layout == "dwindle") (bind b.layout.toggleSplit "hl.dsp.layout(\"togglesplit\")")}
  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      local hy3 = hl.plugin.hy3
      ${bind b.layout.toggleSplit "hy3.make_group(\"opposite\", { toggle = true })"}
      ${bind b.layout.vertical "hy3.make_group(\"v\")"}
      ${bind b.layout.horizontal "hy3.make_group(\"h\")"}
      ${bind b.layout.stacking "hy3.change_group(\"toggletab\")"}
      ${bind b.layout.tabbed "hy3.change_group(\"toggletab\")"}
      ${bind b.layout.default "hy3.change_group(\"untab\")"}
      ${bind b.tree.child "hy3.change_focus(\"lower\")"}
      ${bind b.tree.parent "hy3.change_focus(\"raise\")"}
      ${bind b.hy3.nextTab "hy3.focus_tab({ direction = \"right\", wrap = true })"}
      ${bind b.hy3.previousTab "hy3.focus_tab({ direction = \"left\", wrap = true })"}
      ${bind b.hy3.equalize "hy3.equalize()"}
      ${bind b.hy3.expand "hy3.expand(\"expand\")"}
      ${bind b.hy3.shrink "hy3.expand(\"shrink\")"}
      ${bind b.hy3.resetExpansion "hy3.expand(\"base\")"}
    end
  ''}

  ${lib.optionalString (layout == "hy3") ''
    if hl.plugin.hy3 ~= nil then
      local hy3 = hl.plugin.hy3
      ${bind b.scratchpad.send "hy3.move_to_workspace(\"special:scratchpad\")"}
    end
  ''}
  ${lib.optionalString (layout != "hy3") (bind b.scratchpad.send "hl.dsp.window.move({ workspace = \"special:scratchpad\" })")}
  ${bind b.scratchpad.toggle "hl.dsp.workspace.toggle_special(\"scratchpad\")"}

  ${bind b.session.logout "hl.dsp.exec_cmd(\"qs -c \" .. qsConfigName .. \" ipc call logout open\")"}
  ${bind b.audio.volumeUp "hl.dsp.exec_cmd(\"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+\")"}
  ${bind b.audio.volumeDown "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")"}
  ${bind b.audio.mute "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")"}
  ${bind b.audio.microphoneMute "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\")"}
  ${bind b.brightness.up "hl.dsp.exec_cmd(\"brightnessctl s 10%+\")"}
  ${bind b.brightness.down "hl.dsp.exec_cmd(\"brightnessctl s 10%-\")"}
  ${bind b.media.next "hl.dsp.exec_cmd(\"playerctl next\")"}
  ${bind b.media.pause "hl.dsp.exec_cmd(\"playerctl play-pause\")"}
  ${bind b.media.play "hl.dsp.exec_cmd(\"playerctl play-pause\")"}
  ${bind b.media.previous "hl.dsp.exec_cmd(\"playerctl previous\")"}

  for i = 1, 10 do
    local key = i % 10
    hl.bind(${modifier} .. " + " .. key, hl.dsp.focus({ workspace = i }))
    ${lib.optionalString (layout == "hy3") ''
      if hl.plugin.hy3 ~= nil then
        hl.bind(${modifier} .. " + SHIFT + " .. key, hl.plugin.hy3.move_to_workspace(tostring(i), { follow = false }))
      end
    ''}
    ${lib.optionalString (layout != "hy3") ''
      hl.bind(${modifier} .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
    ''}
  end
  hl.bind(${modifier} .. " + CTRL + RIGHT", hl.dsp.focus({ workspace = "e+1" }))
  hl.bind(${modifier} .. " + CTRL + LEFT", hl.dsp.focus({ workspace = "e-1" }))

  ${lib.optionalString (b.mouse.enable && b.enable) ''
    hl.bind(${mouseModifier} .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(${mouseModifier} .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
    ${lib.optionalString (layout == "hy3") ''
      if hl.plugin.hy3 ~= nil then
        local hy3 = hl.plugin.hy3
        hl.bind(${mouseModifier} .. " + mouse:274", hy3.kill_active(), { mouse = true })
      end
    ''}
    ${lib.optionalString (layout != "hy3") ''
      hl.bind(${mouseModifier} .. " + mouse:274", hl.dsp.window.close(), { mouse = true })
    ''}
  ''}
''
