{ layout }:
let
  layoutConfig =
    {
      dwindle = ''
        hl.config({
            dwindle = {
                preserve_split = true,
            },
        })
      '';
      master = ''
        hl.config({
            master = {
                new_status = "master",
            },
        })
      '';
      scrolling = ''
        hl.config({
            scrolling = {
                fullscreen_on_one_column = true,
            },
        })
      '';
      hy3 = ''
        if hl.plugin.hy3 ~= nil then
          hl.config({
              plugin = {
                  hy3 = {
                      group_inset = 2,
                      node_collapse_policy = 2,
                      tabs = {
                          height = 22,
                          padding = 0,
                          radius = 0,
                          border_width = 2,
                          render_text = true,
                          text_center = true,
                          text_font = "JetBrainsMono Nerd Font",
                          text_height = 8,
                          text_padding = 0,
                          opacity = 1.0,
                          colors = {
                              active = _rgba(COLORS.background),
                              active_border = _rgba(COLORS.primary),
                              active_text = _rgba(COLORS.primary),
                              active_alt_monitor = _rgba(COLORS.background),
                              active_alt_monitor_border = _rgba(COLORS.outline),
                              active_alt_monitor_text = _rgba(COLORS.on_background),
                              focused = _rgba(COLORS.background),
                              focused_border = _rgba(COLORS.secondary),
                              focused_text = _rgba(COLORS.secondary),
                              inactive = _rgba(COLORS.background),
                              inactive_border = _rgba(COLORS.outline_variant),
                              inactive_text = _rgba(COLORS.on_surface_variant),
                              urgent = _rgba(COLORS.background),
                              urgent_border = _rgba(COLORS.error),
                              urgent_text = _rgba(COLORS.error),
                          },
                      },
                  },
              },
          })
        end
      '';
    }
    .${layout};
in
''
  hl.config({
      general = {
          layout = "${layout}",
      },
  })

  ${layoutConfig}
''
