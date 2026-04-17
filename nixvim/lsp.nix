{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim = {
      plugins = {
        lsp = {
          enable = true;

          servers = {
            nixd.enable = true;
            lua_ls.enable = true;

            # texlab = {
            #   enable = config.minima.tex.enable;
            #
            #   settings.texlab = {
            #     build = {
            #       executable = "latexmk";
            #       args = [
            #         "-pdf"
            #         "-interaction=nonstopmode"
            #         "-synctex=1"
            #       ];
            #       onSave = true;
            #     };
            #
            #     chktex = {
            #       onOpenAndSave = true;
            #       onEdit = true;
            #     };
            #   };
            # };
          };
        };

        cmp = {
          enable = true;
          autoEnableSources = true;

          settings = {
            sources = [
              { name = "nvim_lsp"; }
              { name = "buffer"; }
              { name = "path"; }
              { name = "luasnip"; }
              { name = "vimtex"; }
              { name = "latex_symbols"; }
            ];

            mapping = {
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.abort()";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<Tab>" = "cmp.mapping.select_next_item()";
              "<S-Tab>" = "cmp.mapping.select_prev_item()";
            };
          };
        };

        cmp-nvim-lsp.enable = true;
        cmp-buffer.enable = true;
        cmp-path.enable = true;
        cmp_luasnip.enable = true;
        cmp-vimtex.enable = config.minima.tex.enable;
        friendly-snippets.enable = true;

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
            imaps_enabled = 1;

            compiler_latexmk = {
              continuous = 1;
              callback = 1;
              build_dir = "";
              options = [
                "-pdf"
                "-interaction=nonstopmode"
                "-synctex=1"
                "-file-line-error"
                "-shell-escape"
              ];
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
  };
}
