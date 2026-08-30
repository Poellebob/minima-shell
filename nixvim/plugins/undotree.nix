{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.undotree.enable = true;

    programs.nixvim.keymaps = lib.mkIf config.programs.nixvim.plugins.undotree.enable [
      {
        mode = "n";
        key = "<leader>fu";
        action = "<cmd>UndotreeToggle<CR>";
        options.desc = "Undo history";
      }
    ];
  };
}
