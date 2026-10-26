{ config, lib, ... }:
with lib;
{
  options.minima.vim = {
    enable = lib.mkOption {
      description = "Nixvim editor";
      type = types.bool;
      default = true;
    };

    theme = {
      name = mkOption {
        type = types.str;
        default = "catppuccin";
        description = "Theme name";
      };
      flavour = mkOption {
        type = types.str;
        default = "mocha";
      };
    };

    lsp = {
      servers = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = ''
          Extra LSP servers to enable. Each key is a server name.

          Example:
            lsp.servers = {
              pyright.enable = true;
              clangd.enable = true;
              rust_analyzer = {
                enable = true;
                installCargo = false;
                installRustc = false;
              };
            };
        '';
      };
      formatter = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Extra conform formatters by filetype";
      };
      formatterOpts = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        description = "Formatter definitions (e.g. custom args for formatters)";
      };
    };

    vimtex.viewer = {
      method = mkOption {
        type = types.str;
        default = "general";
        example = "zathura";
        description = "VimTeX PDF viewer method (e.g. general, zathura, mupdf, skim).";
      };
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Optional PDF viewer package added to Neovim's PATH. Nixvim installs Zathura and MuPDF automatically for their viewer methods.";
      };
      executable = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "okular";
        description = "Executable for the general viewer method; null uses VimTeX's system PDF opener.";
      };
      options = mkOption {
        type = types.str;
        default = "@pdf";
        example = "--unique @pdf#src:@line@tex";
        description = "Arguments for the general viewer method, supporting VimTeX's @pdf, @tex, @line and @col placeholders.";
      };
    };

    keybinds = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            mode = mkOption {
              type = types.str;
              default = "n";
            };
            key = mkOption {
              type = types.str;
            };
            action = mkOption {
              type = types.str;
            };
            desc = mkOption {
              type = types.str;
              default = "";
            };
          };
        }
      );
      default = [ ];
      description = "Extra keybindings";
    };

    autocmd = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            event = mkOption {
              type = types.either types.str (types.listOf types.str);
            };
            pattern = mkOption {
              type = types.either types.str (types.listOf types.str);
              default = "*";
            };
            command = mkOption {
              type = types.str;
            };
            desc = mkOption {
              type = types.str;
              default = "";
            };
          };
        }
      );
      default = [ ];
      description = "Extra autocommands";
    };
  };

  imports = [
    ./nixvim/options.nix
    ./nixvim/keymaps.nix
    ./nixvim/autocommands.nix
    ./nixvim/performance.nix
  ]
  ++ map (name: ./nixvim/plugins/${name}) (
    lib.filter (name: lib.hasSuffix ".nix" name) (attrNames (builtins.readDir ./nixvim/plugins))
  )
  ++ map (name: ./nixvim/languages/${name}) (
    lib.filter (name: lib.hasSuffix ".nix" name) (attrNames (builtins.readDir ./nixvim/languages))
  );
}
