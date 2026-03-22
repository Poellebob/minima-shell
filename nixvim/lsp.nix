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
                if vim.bo.filetype ~= "qml" then
                  require("conform").format({ bufnr = bufnr })
                end
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
          formatters = config.minima.vim.lsp.formatterOpts;
        };
      };

      vimtex = {
        enable = true;
        settings = {
          view_method = "zathura";
          view_automatic = 1;
          compiler_method = "latexmk";
          quickfix_mode = 0;
          compiler_latexmk = {
            continuous = 1;
            callback = 1;
            build_dir = "";
            options = [
              "-pdf"
              "-verbose"
              "-file-line-error"
              "-synctex=1"
              "-interaction=nonstopmode"
              "-shell-escape"
            ];
          };
        };
      };
    };
  };
}
