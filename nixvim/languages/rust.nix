{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
      };

      conform-nvim.settings.formatters_by_ft.rust = [ "rustfmt" ];
      conform-nvim.settings.formatters.rustfmt.command = lib.getExe pkgs.rustfmt;
    };
  };
}
