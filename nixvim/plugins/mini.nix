{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.mini = {
      enable = true;
      mockDevIcons = true;

      modules = {
        basics = {
          options.extra_ui = true;
          mappings.windows = true;
        };
        ai = { };
        icons = { };
        bracketed = { };
        pairs = { };
        surround = { };
        bufremove = { };
        visits = { };
        extra = { };
        move = {
          mappings = {
            left = "<C-M-h>";
            right = "<C-M-l>";
            down = "<C-M-j>";
            up = "<C-M-k>";

            line_left = "<C-M-h>";
            line_right = "<C-M-l>";
            line_down = "<C-M-j>";
            line_up = "<C-M-k>";
          };
        };
        cursorword = { };
        jump = { };
        jump2d = { };
        indentscope = {
          symbol = "▏";
          options = {
            try_as_border = true;
          };
        };
      };
    };

    programs.nixvim.keymaps =
        lib.optionals
          (
            config.programs.nixvim.plugins.mini.enable
            && lib.hasAttr "bufremove" config.programs.nixvim.plugins.mini.modules
          )
          [
            {
              mode = "n";
              key = "<leader>x";
              action.__raw = "MiniBufremove.delete";
            }
          ]
      ++
        lib.optionals
          (
            config.programs.nixvim.plugins.mini.enable
            && lib.hasAttr "visits" config.programs.nixvim.plugins.mini.modules
          )
          [
            {
              mode = "n";
              key = "<leader>v";
              action.__raw = "MiniVisits.select_path";
            }
          ]
      ++
        lib.optionals
          (
            config.programs.nixvim.plugins.mini.enable
            && lib.hasAttr "extra" config.programs.nixvim.plugins.mini.modules
          )
          [
            {
              mode = "n";
              key = "<leader>ms";
              action.__raw = "MiniExtra.pickers.spellsuggest";
            }
          ];
  };
}
