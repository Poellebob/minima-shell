{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.lsp.servers.clangd = {
      enable = true;
      config = {
        cmd = [
          "clangd"
          "--background-index"
          "--clang-tidy"
        ];
        filetypes = [ "c" "cpp" ];
        root_markers = [ "compile_commands.json" "compile_flags.txt" ".clangd" ".git" ];
      };
    };
  };
}
