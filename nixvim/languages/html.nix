{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.html.enable = true;

      lint.linters.htmlhint.cmd = lib.getExe pkgs.htmlhint;
      lint.lintersByFt.html = [ "htmlhint" ];
    };
  };
}
