{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.lsp.servers.omnisharp.enable = true;
  };
}
