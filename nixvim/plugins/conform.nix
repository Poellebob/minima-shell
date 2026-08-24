{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.conform-nvim = {
      enable = true;

      settings = {
        notify_on_error = true;
        format_on_save = {
          lsp_format = "fallback";
        };
        formatters_by_ft = config.minima.vim.lsp.formatter;
        formatters = config.minima.vim.lsp.formatterOpts;
      };
    };
  };
}
