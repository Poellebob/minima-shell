{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.marksman.enable = true;

      lint.linters.markdownlint.cmd = lib.getExe pkgs.markdownlint-cli;
      lint.lintersByFt.markdown = [ "markdownlint" ];
    };
  };
}
