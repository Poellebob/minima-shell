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
                          text_font = "Sans",
                          text_height = 8,
                          text_padding = 0,
                          opacity = 1.0,
                          colors = {
                              active = "rgba(101418ff)",
                              active_border = "rgba(9acbfaff)",
                              active_text = "rgba(9acbfaff)",
                              active_alt_monitor = "rgba(101418ff)",
                              active_alt_monitor_border = "rgba(8c9198ff)",
                              active_alt_monitor_text = "rgba(e0e2e8ff)",
                              focused = "rgba(101418ff)",
                              focused_border = "rgba(b9c8daff)",
                              focused_text = "rgba(b9c8daff)",
                              inactive = "rgba(101418ff)",
                              inactive_border = "rgba(42474eff)",
                              inactive_text = "rgba(c2c7cfff)",
                              urgent = "rgba(101418ff)",
                              urgent_border = "rgba(ffb4abff)",
                              urgent_text = "rgba(ffb4abff)",
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
