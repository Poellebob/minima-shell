{ lib, colors }:
let
  rgba = c: let
    h = lib.removePrefix "#" c;
  in "rgba(${h}ff)";
in ''
  hl.config({
      general = {
          col = {
              active_border = "${rgba colors.primary}",
              inactive_border = "${rgba colors.outline}",
          },
      },
      decoration = {
          rounding = 0,
          shadow = {
              enabled = false,
          },
          blur = {
              enabled = false,
          },
      },
  })
''