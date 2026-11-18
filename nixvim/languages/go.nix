{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.gopls.enable = true;

      conform-nvim.settings.formatters_by_ft.go = [
        "goimports"
        "gofmt"
      ];
      conform-nvim.settings.formatters.goimports.command = lib.getExe' pkgs.gotools "goimports";
      conform-nvim.settings.formatters.gofmt.command = lib.getExe' pkgs.go "gofmt";
    };
  };
}
