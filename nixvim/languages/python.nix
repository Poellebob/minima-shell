{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.pyright.enable = true;

      lint.linters.ruff.cmd = lib.getExe pkgs.ruff;
      lint.linters.mypy.cmd = lib.getExe pkgs.mypy;
      lint.lintersByFt.python = [
        "ruff"
        "mypy"
      ];

      conform-nvim.settings.formatters_by_ft.python = [ "ruff_fix" ];
      conform-nvim.settings.formatters.ruff_fix.command = lib.getExe pkgs.ruff;
    };
  };
}
