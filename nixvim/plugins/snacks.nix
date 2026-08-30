{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.snacks = {
      enable = true;

      settings = {
        notifier = {
          enabled = true;
        };
      };
    };

    programs.nixvim.keymaps = lib.mkIf config.programs.nixvim.plugins.snacks.enable [
      {
        mode = [
          "n"
          "t"
        ];
        key = "<C-'>";
        action = "<cmd>lua Snacks.terminal.toggle()<CR>";
        options.desc = "Toggle terminal";
      }
      {
        mode = "n";
        key = "<leader>tf";
        action = "<cmd>lua Snacks.terminal.toggle(nil, { win = { style = 'float' } })<CR>";
        options.desc = "Floating terminal";
      }
      {
        mode = "n";
        key = "<leader>th";
        action = "<cmd>lua Snacks.terminal.toggle(nil, { win = { position = 'bottom' } })<CR>";
        options.desc = "Horizontal terminal";
      }
      {
        mode = "n";
        key = "<leader>tv";
        action = "<cmd>lua Snacks.terminal.toggle(nil, { win = { position = 'right' } })<CR>";
        options.desc = "Vertical terminal";
      }
      {
        mode = "n";
        key = "<leader>tl";
        action = "<cmd>lua Snacks.terminal.toggle('lazygit')<CR>";
        options.desc = "Lazygit";
      }
      {
        mode = "n";
        key = "<leader>uD";
        action = "<cmd>lua Snacks.notifier.hide()<CR>";
        options.desc = "Dismiss notifications";
      }
    ];
  };
}
