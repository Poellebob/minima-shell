{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.yamlls.enable = true;

      lint.linters.yamllint.cmd = lib.getExe pkgs.yamllint;
      lint.lintersByFt.yaml = [ "yamllint" ];

      conform-nvim.settings.formatters_by_ft.yaml = [ "yamlfmt" ];
      conform-nvim.settings.formatters.yamlfmt.command = lib.getExe pkgs.yamlfmt;
    };
  };
}
