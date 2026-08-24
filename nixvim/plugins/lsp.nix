{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lspkind.enable = true;
      lsp-lines.enable = true;
      lsp-signature.enable = true;

      lsp = {
        enable = true;
        inlayHints = true;

        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gi" = "implementation";
            "K" = "hover";
            "<leader>ca" = "code_action";
          };

          extra = [
            {
              key = "<leader>ih";
              action = ''vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())'';
            }
          ];
        };

        servers = config.minima.vim.lsp.servers;
      };
    };
  };
}
