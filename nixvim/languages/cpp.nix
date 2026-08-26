{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.clangd.enable = true;

      lint.linters.cppcheck.cmd = "${pkgs.cppcheck}/bin/cppcheck";
      lint.lintersByFt.c = [ "cppcheck" ];
      lint.lintersByFt.cpp = [ "cppcheck" ];

      conform-nvim.settings.formatters_by_ft.c = [ "clang_format" ];
      conform-nvim.settings.formatters_by_ft.cpp = [ "clang_format" ];
      conform-nvim.settings.formatters.clang_format.command = "${pkgs.clang-tools}/bin/clang-format";
    };
  };
}
