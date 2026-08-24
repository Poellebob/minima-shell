{ config, lib, ... }:

let
  mkKeymaps =
    mode: attrs:
    lib.mapAttrsToList (
      key: { action, ... }@attrs:
      {
        inherit mode key action;
        options = { silent = true; } // (attrs.options or { });
      }
    ) attrs;
in
{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim = {
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      keymaps =
        mkKeymaps "n" {
          "<space>" = {
            action = "<NOP>";
          };

          "<esc>" = {
            action = "<cmd>nohlsearch<cr>";
          };

          "<leader>w" = {
            action = "<cmd>w<cr>";
            options.desc = "Save File";
          };

          "<leader>q" = {
            action = "<Cmd>confirm q<CR>";
            options.desc = "Quit";
          };

          "j" = {
            action = "v:count == 0 ? 'gj' : 'j'";
            options = {
              desc = "Move cursor down";
              expr = true;
            };
          };

          "k" = {
            action = "v:count == 0 ? 'gk' : 'k'";
            options = {
              desc = "Move cursor up";
              expr = true;
            };
          };

          "Y" = {
            action = "y$";
          };

          "<c-d>" = {
            action = "<c-d>zz";
          };

          "<c-u>" = {
            action = "<c-u>zz";
          };
        }
        ++ mkKeymaps "i" {
          "jk" = {
            action = "<esc>";
          };
        }
        ++ map (k: {
          mode = k.mode;
          key = k.key;
          action = k.action;
          options.desc = k.desc;
        }) config.minima.vim.keybinds;
    };
  };
}
