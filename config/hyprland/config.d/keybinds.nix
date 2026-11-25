{
  lib,
  pkgs,
  layout,
  keybinds,
  terminalEnabled,
  bind,
  mouseModifier,
}:
let
  luaStr = s: "\"" + lib.escape [ "\\" "\"" ] s + "\"";
  workspaceKey = i: if i == 10 then "0" else toString i;
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp -b '#\" .. COLORS.scrim .. \"88' -c '#\" .. COLORS.primary .. \"ff' -s '#\" .. COLORS.primary .. \"22'";
  windowBoxes =
    let
      filter = lib.replaceStrings [ "\n" ] [ " " ] ''
        def fullscreen:
          .fullscreen == true or ((.fullscreen // 0) | numbers > 0);

        map(select(.mapped and (.hidden | not))) as $windows
        | ($windows | map(select(fullscreen) | .workspace.id)) as $fullscreenWorkspaces
        | $windows[]
        | .workspace.id as $id
        | select(any($monitors[];
            .activeWorkspace.id == $id or .specialWorkspace.id == $id))
        | select(.visible != false)
        | select(
            ($fullscreenWorkspaces | index($id)) == null
            or fullscreen
            or .pinned == true
            or .allowedOverFullscreen == true
            or .overFullscreen == true
          )
        | "\(.at | join(",")) \(.size | join("x"))"
      '';

      command = lib.concatStringsSep " " [
        "hyprctl -j clients"
        "| ${pkgs.jq}/bin/jq -r"
        ''--argjson monitors "$(hyprctl -j monitors)"''
        (lib.escapeShellArg filter)
      ];
    in
    lib.escape [ "\\" "\"" ] command;

  magick = "${pkgs.imagemagick}/bin/magick";
  swappy = "${pkgs.swappy}/bin/swappy";
  wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
  b = keybinds;
  nonempty = builtins.filter (line: line != "");
  lines = entries: lib.concatStringsSep "\n" (nonempty entries);
  hy3Block =
    useLocal: entries:
    lib.optionalString (nonempty entries != [ ]) (
      lines (
        [ "if hl.plugin.hy3 ~= nil then" ]
        ++ lib.optional useLocal "  local hy3 = hl.plugin.hy3"
        ++ map (line: "  ${line}") (nonempty entries)
        ++ [ "end" ]
      )
    );

  workspaceBinds = lib.concatMap (i: [
    (bind [ "Main" (workspaceKey i) ] "hl.dsp.focus({ workspace = ${toString i} })")
    (
      if layout == "hy3" then
        hy3Block false [
          (bind [
            "Main"
            "Shift"
            (workspaceKey i)
          ] "hl.plugin.hy3.move_to_workspace(\"${toString i}\", { follow = false })")
        ]
      else
        bind [
          "Main"
          "Shift"
          (workspaceKey i)
        ] "hl.dsp.window.move({ workspace = ${toString i}, follow = false })"
    )
  ]) (lib.range 1 10);

  mouseBind =
    button: action:
    "hl.bind(${luaStr "${mouseModifier} + mouse:${toString button}"}, ${action}, { mouse = true })";

  groups = [
    [
      (lib.optionalString terminalEnabled (
        bind b.terminal "hl.dsp.exec_cmd(\"${pkgs.kitty}/bin/kitty\")"
      ))
      (
        if layout == "hy3" then
          hy3Block true [ (bind b.window.close "hy3.kill_active()") ]
        else
          bind b.window.close "hl.dsp.window.close()"
      )
      (bind b.window.floating "hl.dsp.window.float()")
      (bind b.window.fullscreen "hl.dsp.window.fullscreen()")
      (bind b.window.sticky "hl.dsp.window.pin()")
      (bind b.session.lock "hl.dsp.exec_cmd(\"qs -c \" .. qsConfigName .. \" ipc call minimaLock open\")")
      (bind b.session.reload "hl.dsp.exec_cmd(\"hyprctl reload\")")
      (bind b.session.clipboard "hl.dsp.exec_cmd(\"qs -c \" .. qsConfigName .. \" ipc call clipboard open\")")
      (bind b.session.launcher "hl.dsp.exec_cmd(\"qs -c \" .. qsConfigName .. \" ipc call launcher open\")")
    ]
    [
      (bind b.screenshot.selection "hl.dsp.exec_cmd(\"${grim} -g \\\"$(${windowBoxes}| ${slurp} -o -d)\\\" - | ${magick} - -shave 1x1 PNG:- | ${wlCopy}\")")
      (bind b.screenshot.fullscreen "hl.dsp.exec_cmd(\"${grim} - | ${wlCopy}\")")
      (bind b.screenshot.editSelection "hl.dsp.exec_cmd(\"${grim} -g \\\"$(${windowBoxes}| ${slurp} -o -d)\\\" - | ${swappy} -f -\")")
      (bind b.screenshot.editFullscreen "hl.dsp.exec_cmd(\"${grim} - | ${swappy} -f -\")")
    ]
    (
      if layout == "hy3" then
        [
          (hy3Block true [
            (bind b.focus.left "hy3.move_focus(\"left\")")
            (bind b.focus.right "hy3.move_focus(\"right\")")
            (bind b.focus.up "hy3.move_focus(\"up\")")
            (bind b.focus.down "hy3.move_focus(\"down\")")
          ])
        ]
      else
        [
          (bind b.focus.left "hl.dsp.focus({ direction = \"left\" })")
          (bind b.focus.right "hl.dsp.focus({ direction = \"right\" })")
          (bind b.focus.up "hl.dsp.focus({ direction = \"up\" })")
          (bind b.focus.down "hl.dsp.focus({ direction = \"down\" })")
        ]
    )
    (
      if layout == "hy3" then
        [
          (hy3Block false [
            (bind b.move.left "hl.plugin.hy3.move_window(\"left\", { once = true })")
            (bind b.move.right "hl.plugin.hy3.move_window(\"right\", { once = true })")
            (bind b.move.up "hl.plugin.hy3.move_window(\"up\", { once = true })")
            (bind b.move.down "hl.plugin.hy3.move_window(\"down\", { once = true })")
          ])
        ]
      else
        [
          (bind b.move.left "hl.dsp.window.move({ direction = \"left\" })")
          (bind b.move.right "hl.dsp.window.move({ direction = \"right\" })")
          (bind b.move.up "hl.dsp.window.move({ direction = \"up\" })")
          (bind b.move.down "hl.dsp.window.move({ direction = \"down\" })")
        ]
    )
    [
      (bind b.resize.shrinkWidth "hl.dsp.window.resize({ x = -100, y = 0, relative = true })")
      (bind b.resize.growWidth "hl.dsp.window.resize({ x = 100, y = 0, relative = true })")
      (bind b.resize.shrinkHeight "hl.dsp.window.resize({ x = 0, y = -100, relative = true })")
      (bind b.resize.growHeight "hl.dsp.window.resize({ x = 0, y = 100, relative = true })")
    ]
    (
      if layout == "hy3" then
        [
          (hy3Block true [
            (bind b.layout.toggleSplit "hy3.make_group(\"opposite\", { toggle = true })")
            (bind b.layout.vertical "hy3.make_group(\"v\")")
            (bind b.layout.horizontal "hy3.make_group(\"h\")")
            (bind b.layout.stacking "hy3.change_group(\"toggletab\")")
            (bind b.layout.tabbed "hy3.change_group(\"toggletab\")")
            (bind b.layout.default "hy3.change_group(\"untab\")")
            (bind b.tree.child "hy3.change_focus(\"lower\")")
            (bind b.tree.parent "hy3.change_focus(\"raise\")")
            (bind b.hy3.nextTab "hy3.focus_tab({ direction = \"right\", wrap = true })")
            (bind b.hy3.previousTab "hy3.focus_tab({ direction = \"left\", wrap = true })")
            (bind b.hy3.equalize "hy3.equalize()")
            (bind b.hy3.expand "hy3.expand(\"expand\")")
            (bind b.hy3.shrink "hy3.expand(\"shrink\")")
            (bind b.hy3.resetExpansion "hy3.expand(\"base\")")
          ])
        ]
      else
        lib.optional (layout == "dwindle") (bind b.layout.toggleSplit "hl.dsp.layout(\"togglesplit\")")
    )
    [
      (
        if layout == "hy3" then
          hy3Block true [ (bind b.scratchpad.send "hy3.move_to_workspace(\"special:scratchpad\")") ]
        else
          bind b.scratchpad.send "hl.dsp.window.move({ workspace = \"special:scratchpad\" })"
      )
      (bind b.scratchpad.toggle "hl.dsp.workspace.toggle_special(\"scratchpad\")")
    ]
    [
      (bind b.session.logout "hl.dsp.exec_cmd(\"qs -c \" .. qsConfigName .. \" ipc call logout open\")")
      (bind b.audio.volumeUp "hl.dsp.exec_cmd(\"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+\")")
      (bind b.audio.volumeDown "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")")
      (bind b.audio.mute "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")")
      (bind b.audio.microphoneMute "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\")")
      (bind b.brightness.up "hl.dsp.exec_cmd(\"brightnessctl s 10%+\")")
      (bind b.brightness.down "hl.dsp.exec_cmd(\"brightnessctl s 10%-\")")
      (bind b.media.next "hl.dsp.exec_cmd(\"playerctl next\")")
      (bind b.media.pause "hl.dsp.exec_cmd(\"playerctl play-pause\")")
      (bind b.media.play "hl.dsp.exec_cmd(\"playerctl play-pause\")")
      (bind b.media.previous "hl.dsp.exec_cmd(\"playerctl previous\")")
    ]
    (
      workspaceBinds
      ++ [
        (bind [ "Main" "Ctrl" "RIGHT" ] ''hl.dsp.focus({ workspace = "e+1" })'')
        (bind [ "Main" "Ctrl" "LEFT" ] ''hl.dsp.focus({ workspace = "e-1" })'')
      ]
    )
    (lib.optionals (b.mouse.enable && b.enable) [
      (mouseBind 272 "hl.dsp.window.drag()")
      (mouseBind 273 "hl.dsp.window.resize()")
      (
        if layout == "hy3" then
          hy3Block true [ (mouseBind 274 "hy3.kill_active()") ]
        else
          mouseBind 274 "hl.dsp.window.close()"
      )
    ])
  ];
  sections = nonempty (map lines groups);
in
lib.concatMapStringsSep "\n" (section: section + "\n") sections
