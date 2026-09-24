{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.noice = {
      enable = true;
      settings = {
        lsp = {
          override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
        };
        views = {
          cmdline_popup.border.style = "single";
          cmdline_input.border.style = "single";
          confirm.border.style = "single";
          popup.border.style = "single";
          hover.border.style = "single";
        };
      };
    };
  };
}
