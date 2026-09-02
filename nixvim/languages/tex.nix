{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.lsp.servers.ltex = {
      enable = true;
      settings = {
        loadLangs = [ "en-US" ];
      };
    };
  };
}
