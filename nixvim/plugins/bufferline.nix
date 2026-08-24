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
    );
  };
}
