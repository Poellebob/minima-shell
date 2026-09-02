{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.conform-nvim.settings = {
      formatters_by_ft.javascript = [ "prettierd" ];
      formatters.prettierd.command = lib.getExe pkgs.prettierd;
    };
  };
}
