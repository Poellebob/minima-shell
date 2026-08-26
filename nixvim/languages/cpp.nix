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
      # Used for PlatformIO projects
      ccls = {
        enable = true;
        package = pkgs.ccls;
        {  
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
        }

        root_dir = mkRaw ''
          function(fname, bufnr)
            local util = require("lspconfig.util")
            return util.root_pattern("platformio.ini")(fname)
          end
        '';
      };

      # Used for everything else
      clangd = {
        enable = true;
        cmd = [
          "clangd"
          "--background-index"
          "--clang-tidy"
        ];
        filetypes = [ "c" "cpp" ];
        root_dir = mkRaw ''
          function(fname, bufnr)
            local util = require("lspconfig.util")
            -- bail out if this is a PlatformIO project; let ccls take it
            if util.root_pattern("platformio.ini")(fname) then
              return nil
            end
            return util.root_pattern(
              "compile_commands.json",
              "compile_flags.txt",
              ".clangd",
              ".git"
            )(fname)
          end
        '';
      };
    };
  };
}
