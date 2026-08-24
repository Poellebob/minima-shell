{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.toggleterm = {
      enable = true;

      settings = {
        winbar.enable = true;
        shade_terminals = true;
      };
    };

    programs.nixvim.keymaps = lib.mkIf config.programs.nixvim.plugins.toggleterm.enable [
      {
        mode = "n";
        key = "<leader>tt";
        action = "<cmd>ToggleTerm direction=horizontal<cr>";
      }
      {
        mode = "n";
        key = "<leader>tf";
        action = "<cmd>ToggleTerm direction=float<cr>";
      }
      {
        mode = "t";
        key = "<esc><esc>";
        action = "<C-\\><C-n>";
        options.desc = "Exit Terminal Mode";
      }
    ];
  };
}
