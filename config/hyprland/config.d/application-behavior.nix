{ layout }:
''
  -- Application Behavior and Rules

  -- Window rules
  -- Float utility windows
  hl.window_rule({ match = { class = "^(nmtui|bluedevil-wizard)$" }, float = true })

  -- VR applications
  hl.window_rule({ match = { class = "^(vrmonitor)$" }, float = true })
  hl.window_rule({ match = { title = "^(SteamVR.*)$" }, float = true })

  -- Xwayland drag fix
  hl.window_rule({ match = { class = "^$", title = "^$" }, float = true, border_size = 0 })

  ${if layout == "scrolling" then ''
  -- Layout settings
  hl.config({ scrolling = { column_width = 0.5, explicit_column_widths = { 0.33333333, 0.5, 0.66666667, 1.0 } } })
  '' else ""}

  ${if layout == "dwindle" then ''
  -- Layout settings
  hl.config({ dwindle = { preserve_split = true } })
  '' else ""}
''
