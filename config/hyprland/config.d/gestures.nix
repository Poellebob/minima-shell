''
  hl.config({
      gestures = {
          workspace_swipe_direction_lock = false,
          workspace_swipe_forever = true,
          workspace_swipe_cancel_ratio = 0.15,
      },
  })

  hl.gesture({
      fingers = 3,
      direction = "horizontal",
      action = "workspace",
  })
''
