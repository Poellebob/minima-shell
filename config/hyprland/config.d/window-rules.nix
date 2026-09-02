''
  hl.window_rule({
      match = { class = "nmtui|bluedevil-wizard" },
      float = true,
  })

  hl.window_rule({
      match = { class = "vrmonitor" },
      float = true,
  })

  hl.window_rule({
      match = { title = "SteamVR.*" },
      float = true,
  })

  hl.window_rule({
      name = "fix-xwayland-drags",
      match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
      no_focus = true,
      border_size = 0,
  })
''
