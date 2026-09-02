''
  hl.config({
      decoration = {
          rounding = 0,
          blur = {
              enabled = true,
              size = 7,
              passes = 4,
              noise = 0.008,
              contrast = 0.8916,
              brightness = 0.8,
              input_methods = true,
          },
          shadow = {
              enabled = false,
              color = _rgba(COLORS.shadow),
          },
      },
      general = {
          col = {
              active_border = _rgba(COLORS.primary),
              inactive_border = _rgba(COLORS.outline),
          },
      },
      group = {
          col = {
              border_active = _rgba(COLORS.secondary),
              border_inactive = _rgba(COLORS.outline),
              border_locked_active = _rgba(COLORS.secondary),
              border_locked_inactive = _rgba(COLORS.outline),
          },
          groupbar = {
              text_color = _rgba(COLORS.on_surface),
              text_color_inactive = _rgba(COLORS.on_surface_variant),
              text_color_locked_active = _rgba(COLORS.on_surface),
              text_color_locked_inactive = _rgba(COLORS.on_surface_variant),
              col = {
                  active = _rgba(COLORS.primary),
                  inactive = _rgba(COLORS.surface_container_high),
                  locked_active = _rgba(COLORS.primary),
                  locked_inactive = _rgba(COLORS.surface_container_high),
              },
          },
      },
  })

  hl.config({
      animations = {
          enabled = true,
      },
  })
''
