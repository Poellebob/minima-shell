{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.lsp.servers.bashls.enable = true;
  };
}
