{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.lua_ls.enable = true;

      lint.linters.luacheck.cmd = lib.getExe pkgs.luaPackages.luacheck;
      lint.lintersByFt.lua = [ "luacheck" ];

      conform-nvim.settings.formatters_by_ft.lua = [ "stylua" ];
      conform-nvim.settings.formatters.stylua.command = lib.getExe pkgs.stylua;
    };
  };
}
