{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.flash = {
      enable = false;

      settings = {
        jump = {
          autojump = true;
        };
      };
    };

    programs.nixvim.keymaps = lib.mkIf config.programs.nixvim.plugins.flash.enable [
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "s";
        action.__raw = ''require("flash").jump'';
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "S";
        action.__raw = ''require("flash").treesitter'';
      }
    ];
  };
}
