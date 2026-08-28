{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.lsp.servers.clangd = {
      enable = true;
      cmd = [
        "clangd"
        "--background-index"
        "-j=12"
        "--query-driver=**"
        "--clang-tidy"
        "--all-scopes-completion"
        "--cross-file-rename"
        "--completion-style=detailed"
        "--header-insertion-decorators"
        "--header-insertion=iwyu"
        "--pch-storage=memory"
        "--suggest-missing-includes"
      ];
      filetypes = [
        "c"
        "cpp"
      ];
    };
  };
}
