{ config, lib, ... }:
{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          lua_ls.enable = true;
        } // config.minima.vim.lsp.servers;
        onAttach = ''
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
              end,
            })
          end
        '';
      };

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
          formatters_by_ft = {
            nix = [ "nixfmt" ];
            lua = [ "stylua" ];
          } // config.minima.vim.lsp.conform;
        };
      };
    };
  };
}
