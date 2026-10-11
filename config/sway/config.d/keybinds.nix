{
  wm,
  pkgs,
  modifier,
  keybinds,
  terminalEnabled,
  bind,
  bindExpr,
}:
let
  msgCmd = if wm == "scroll" then "scrollmsg" else "swaymsg";
  b = keybinds;
in
''
  ${if terminalEnabled then bind b.terminal "exec ${pkgs.kitty}/bin/kitty" else ""}
  ${bind b.window.close "kill"}
  ${bind b.window.floating "floating toggle"}
  ${bind b.window.fullscreen "fullscreen toggle"}
  ${bind b.window.sticky "sticky toggle"}
  ${bind b.session.lock "exec qs -c $qs_config ipc call minimaLock open"}
  ${bind b.session.reload "exec ${msgCmd} reload"}
  ${bind b.session.clipboard "exec qs -c $qs_config ipc call clipboard open"}
  ${bind b.session.launcher "exec qs -c $qs_config ipc call launcher open"}

  ${if wm == "scroll" then ''
    ${bind b.scroll.fullHeight "set_size h 1.0"}
    ${bind b.scroll.halfHeight "set_size h 0.5"}
    ${bind b.scroll.columnLeft "move left nomode after"}
    ${bind b.scroll.columnRight "move right nomode after"}
    ${if b.enable && b.scroll.overview != [ ] then "bindsym --no-repeat ${bindExpr b.scroll.overview} scale_workspace overview" else ""}
    ${bind b.scroll.toggleDirection "set_mode toggle"}
  '' else ""}

  ${bind b.screenshot.selection "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -o -d)\" - | ${pkgs.imagemagick}/bin/magick - -shave 1x1 PNG:- | ${pkgs.wl-clipboard}/bin/wl-copy"}
  ${bind b.screenshot.fullscreen "exec ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy"}
  ${bind b.screenshot.editSelection "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -o -d)\" - | ${pkgs.imagemagick}/bin/magick - -shave 1x1 PNG:- | ${pkgs.swappy}/bin/swappy -f -"}
  ${bind b.screenshot.editFullscreen "exec ${pkgs.grim}/bin/grim - | ${pkgs.swappy}/bin/swappy -f -"}

  ${bind b.focus.left "focus left"}
  ${bind b.focus.right "focus right"}
  ${bind b.focus.up "focus up"}
  ${bind b.focus.down "focus down"}
  ${bind b.move.left "move left"}
  ${bind b.move.right "move right"}
  ${bind b.move.up "move up"}
  ${bind b.move.down "move down"}
  ${bind b.resize.shrinkWidth "resize shrink width 100px"}
  ${bind b.resize.growWidth "resize grow width 100px"}
  ${bind b.resize.shrinkHeight "resize shrink height 100px"}
  ${bind b.resize.growHeight "resize grow height 100px"}

  ${if wm == "sway" || wm == "swayfx" then ''
    ${bind b.layout.toggleSplit "split toggle"}
    ${bind b.layout.vertical "split v"}
    ${bind b.layout.horizontal "split h"}
    ${bind b.layout.stacking "layout stacking"}
    ${bind b.layout.tabbed "layout tabbed"}
    ${bind b.layout.default "layout default"}
    ${bind b.tree.child "focus child"}
    ${bind b.tree.parent "focus parent"}
  '' else ""}

  ${bind b.scratchpad.send "move scratchpad"}
  ${bind b.scratchpad.toggle "scratchpad show"}
  ${bind b.session.logout "exec qs -c $qs_config ipc call minimaLogout open"}
  ${bind b.audio.volumeUp "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"}
  ${bind b.audio.volumeDown "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"}
  ${bind b.audio.mute "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"}
  ${bind b.audio.microphoneMute "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"}
  ${bind b.brightness.up "exec brightnessctl s 10%+"}
  ${bind b.brightness.down "exec brightnessctl s 10%-"}
  ${bind b.media.next "exec playerctl next"}
  ${bind b.media.pause "exec playerctl play-pause"}
  ${bind b.media.play "exec playerctl play-pause"}
  ${bind b.media.previous "exec playerctl previous"}

  ${if b.mouse.enable && b.enable then ''
    floating_modifier ${modifier} normal
    bindsym --whole-window ${modifier}+button2 kill
  '' else ""}
''
