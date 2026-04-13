{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          lua_ls.enable = true;
          #texlab.enable = config.minima.tex.enable;
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
      cmp-nvim-lsp.enable = true;
      cmp-omni.enable = true;
      cmp_luasnip.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;

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
            tex = [ "latexindent" ];
          } // config.minima.vim.lsp.conform;
          formatters = config.minima.vim.lsp.formatterOpts;
        };
      };
      
      cmp-vimtex.enable = config.minima.tex.enable;
      vimtex = {
        enable = config.minima.tex.enable;
        texlivePackage = lib.optionals config.minima.tex.enable (
          pkgs.texlive.combine (
            { ${config.minima.tex.scheme} = pkgs.texlive.${config.minima.tex.scheme}; }
            // lib.optionalAttrs (config.minima.tex.packages != null) config.minima.tex.packages
          )
        );
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

      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "omni"; }
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
            { name = "luasnip"; }
            { name = "vimtex"; }
          ];
          filetype_extend = {
            tex = [ "vimtex" ];
          };
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
          };
        };
      };

      luasnip = {
        enable = true;
        settings = {
          region_check_events = "InsertEnter";
          delete_check_events = "TextChanged,InsertLeave";
        };
      };
    };
  };
}
