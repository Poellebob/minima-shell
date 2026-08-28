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
      clang = {
        enable = true;
        config = {  
          cmd = [
            "clangd"
            "--background-index"
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
