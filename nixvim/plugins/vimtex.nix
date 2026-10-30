{ config, lib, ... }:

let
  viewer = config.minima.vim.vimtex.viewer;
in
{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim = {
      plugins.vimtex = {
        enable = true;
        settings = {
          view_method = viewer.method;
          view_general_options = viewer.options;
        }
        // lib.optionalAttrs (viewer.executable != null) {
          view_general_viewer = viewer.executable;
        };
      };

      extraPackages = lib.optional (viewer.package != null) viewer.package;

      autoCmd = [
        {
          event = "FileType";
          pattern = [
            "tex"
            "plaintex"
          ];
          desc = "LaTeX buffer keymaps";
          callback.__raw = ''
            function(event)
              local mappings = {
                { "ll", "VimtexCompile", "LaTeX compile (toggle)" },
                { "lv", "VimtexView", "LaTeX view PDF / forward search" },
                { "le", "VimtexErrors", "LaTeX errors" },
                { "lt", "VimtexTocToggle", "LaTeX table of contents" },
                { "lk", "VimtexStop", "LaTeX stop compilation" },
                { "lc", "VimtexClean", "LaTeX clean auxiliary files" },
                { "li", "VimtexInfo", "LaTeX project info" },
              }
              for _, mapping in ipairs(mappings) do
                vim.keymap.set("n", "<localleader>" .. mapping[1], "<cmd>" .. mapping[2] .. "<CR>", {
                  buffer = event.buf,
                  silent = true,
                  desc = mapping[3],
                })
              end
            end
          '';
        }
      ];
    };
  };
}
