{ config, lib, ... }: 

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.dap = {
      enable = true;
    };
  };
}