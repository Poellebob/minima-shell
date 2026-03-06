{ config, lib, ... }:
with lib;
{
  options.minima.vim = {
    enable = lib.mkEnableOption "Nixvim editor";

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
        default = {};
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
      conform = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = {};
        description = "Extra conform formatters by filetype";
      };
    };

    keybinds = mkOption {
      type = types.listOf (types.submodule {
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
      });
      default = [];
      description = "Extra keybindings";
    };

    autocmd = mkOption {
      type = types.listOf (types.submodule {
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
      });
      default = [];
      description = "Extra autocommands";
    };

    plugins = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Extra nixvim plugins";
    };
  };

  imports = [
    ./nixvim/options.nix
    ./nixvim/ui.nix
    ./nixvim/lsp.nix
  ];
}
