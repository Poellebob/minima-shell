{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.lualine = {
      enable = true;

      settings = {
        options = {
          global_status = true;

          section_separators = {
            left = "";
            right = "";
          };
          component_separators = {
            left = "";
            right = "";
          };
        };
      };
    };
  };
}
