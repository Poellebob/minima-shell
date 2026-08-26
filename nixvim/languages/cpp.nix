{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.lsp.servers = {
      ccls = {
        enable = true;
        package = pkgs.ccls;
        config = {  
          cmd = [
            "ccls"
          ];
          filetypes = [
            "c"
            "cpp"
            "h"
            "hpp"
          ];
          root_markers = [
            "compile_commands.json"
            "compile_flags.txt"
            ".git"
          ];
        };
      };
    };
  };
}
