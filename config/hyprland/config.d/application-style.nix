{ layout }:
''
  -- Gaps and borders
  hl.config({
    general = { gaps_in = 3, gaps_out = 3, border_size = 2 },
    decoration = {
      rounding = 0,
      shadow = { enabled = true, range = 4, color = "rgba(1a1a1aee)" },
      blur = { enabled = true, size = 4, passes = 2 },
    },
  })

  ${if layout == "scrolling" then ''
  -- Animations
  hl.curve("minima_simple", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
  hl.curve("minima_linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
  hl.curve("minima_move", { type = "bezier", points = { { 0.215, 0.61 }, { 0.355, 1 } } })
  hl.curve("minima_size", { type = "bezier", points = { { -0.35, 0 }, { 0, 0.5 } } })
  hl.animation({ leaf = "global", enabled = true, speed = 0.3, curve = "minima_simple" })
  hl.animation({ leaf = "windowsIn", enabled = true, speed = 0.3, curve = "minima_linear" })
  hl.animation({ leaf = "windowsMove", enabled = true, speed = 0.3, curve = "minima_move" })
  hl.animation({ leaf = "windows", enabled = true, speed = 0.3, curve = "minima_size" })
  '' else ''
  -- Animations
  hl.config({ animations = { enabled = true } })
  ''}
''
