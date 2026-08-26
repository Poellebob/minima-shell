{
  config,
  lib,
  pkgs,
  ...
}:

{
  plugins.lsp = {
    enable = true;

    servers = {
      clangd = {
        enable = true;

        settings = {
          clangd = {
            cmd = [
              "clangd"
              "--background-index"
              "--clang-tidy"
              "--header-insertion=iwyu"
              "--completion-style=detailed"
            ];
          };
        };
      };
    };
  };
}
