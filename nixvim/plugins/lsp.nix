{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lspkind.enable = true;
      lsp-lines.enable = true;

      lsp = {
        enable = true;
        inlayHints = false;

        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gi" = "implementation";
            "K" = "hover";
            "<leader>ca" = "code_action";
          };
        };

        servers = config.minima.vim.lsp.servers;
      };
    };
  };
}
