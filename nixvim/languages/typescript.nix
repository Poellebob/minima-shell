{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.ts_ls.enable = true;

      conform-nvim.settings.formatters_by_ft.typescript = [ "prettierd" ];
      conform-nvim.settings.formatters.prettierd.command = lib.getExe pkgs.prettierd;
    };
  };
}
