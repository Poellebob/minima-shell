{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.colorschemes.catppuccin.settings = {
      default_integrations = true;
      show_end_of_buffer = true;
      term_colors = true;
      transparent_background = false;

      integrations = {
        blink_cmp = true;
        gitsigns = true;
        lsp_trouble = true;
        markdown = true;
        mini.enabled = true;
        native_lsp = {
          enabled = true;
          virtual_text = {
            errors = [ "italic" ];
            hints = [ "italic" ];
            warnings = [ "italic" ];
            information = [ "italic" ];
          };
          underlines = {
            errors = [ "underline" ];
            hints = [ "underline" ];
            warnings = [ "underline" ];
            information = [ "underline" ];
          };
          inlay_hints = {
            background = true;
          };
        };
        treesitter = true;
      };
    };
  };
}
