{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.bufferline = {
      enable = true;

      settings = {
        options = {
          mode = "buffers";
          always_show_bufferline = true;
          diagnostics = "nvim_lsp";

          diagnostics_indicator = ''
            function(count, level)
              local icon = level:match("error") and " " or " "
              return " " .. icon .. count
            end
          '';
          numbers = "ordinal";
          show_buffer_close_icons = false;
          show_close_icon = false;
          show_tab_indicators = false;
        };
      };
    };

    programs.nixvim.keymaps = lib.mkIf config.programs.nixvim.plugins.bufferline.enable (
      lib.map (n: {
        mode = "n";
        key = "g${toString n}";
        action = "<cmd>BufferLineGoToBuffer ${toString n}<cr>";
      }) (lib.range 1 9)
      ++
        [
          {
            mode = "n";
            key = "<leader>c";
            action = "<cmd>Bdelete<CR>";
            options.desc = "Close buffer";
          }
          {
            mode = "n";
            key = ">b";
            action = "<cmd>BufferLineMoveNext<CR>";
            options.desc = "Move buffer right";
          }
          {
            mode = "n";
            key = "<b";
            action = "<cmd>BufferLineMovePrev<CR>";
            options.desc = "Move buffer left";
          }
          {
            mode = "n";
            key = "<leader>bc";
            action = "<cmd>BufferLineCloseOthers<CR>";
            options.desc = "Close other buffers";
          }
          {
            mode = "n";
            key = "<leader>bp";
            action = "<cmd>BufferLineCyclePrev<CR>";
            options.desc = "Prev buffer";
          }
          {
            mode = "n";
            key = "<leader>bl";
            action = "<cmd>BufferLineCloseLeft<CR>";
            options.desc = "Close buffers left";
          }
          {
            mode = "n";
            key = "<leader>br";
            action = "<cmd>BufferLineCloseRight<CR>";
            options.desc = "Close buffers right";
          }
        ]
    );
  };
}
