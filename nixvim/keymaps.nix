{ config, lib, ... }:

let
  mkKeymaps =
    mode: attrs:
    lib.mapAttrsToList (
      key:
      { action, ... }@attrs:
      {
        inherit mode key action;
        options = {
          silent = true;
        }
        // (attrs.options or { });
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
        ++ mkKeymaps "v" {
          "aa" = {
            action = "<Esc>gg_vG$";
            options.desc = "Select all";
          };
          "<Tab>" = {
            action = ">gv";
            options.desc = "Indent right";
          };
          "<S-Tab>" = {
            action = "<gv";
            options.desc = "Indent left";
          };
        }
        ++ mkKeymaps "i" {
          "jk" = {
            action = "<esc>";
          };
          "jj" = {
            action = "<esc>";
          };
        }
        ++ mkKeymaps "n" {
          # ── Window navigation ─────────────────────────────────────────────
          "<C-h>" = {
            action = "<C-w>h";
            options.desc = "Left window";
          };
          "<C-j>" = {
            action = "<C-w>j";
            options.desc = "Down window";
          };
          "<C-k>" = {
            action = "<C-w>k";
            options.desc = "Up window";
          };
          "<C-l>" = {
            action = "<C-w>l";
            options.desc = "Right window";
          };
          "<C-Up>" = {
            action = "<cmd>resize +2<CR>";
            options.desc = "Resize up";
          };
          "<C-Down>" = {
            action = "<cmd>resize -2<CR>";
            options.desc = "Resize down";
          };
          "<C-Left>" = {
            action = "<cmd>vertical resize -2<CR>";
            options.desc = "Resize left";
          };
          "<C-Right>" = {
            action = "<cmd>vertical resize +2<CR>";
            options.desc = "Resize right";
          };

          # ── Splits ────────────────────────────────────────────────────────
          "\\" = {
            action = "<cmd>split<CR>";
            options.desc = "Horizontal split";
          };
          "|" = {
            action = "<cmd>vsplit<CR>";
            options.desc = "Vertical split";
          };

          # ── File / buffer management ──────────────────────────────────────
          "<C-s>" = {
            action = "<cmd>w!<CR>";
            options.desc = "Force write";
          };
          "<C-q>" = {
            action = "<cmd>q!<CR>";
            options.desc = "Force quit";
          };
          "<leader>n" = {
            action = "<cmd>enew<CR>";
            options.desc = "New file";
          };
          "<leader>c" = {
            action.__raw = "MiniBufremove.delete";
            options.desc = "Close buffer";
          };
          "]b" = {
            action = "<cmd>bnext<CR>";
            options.desc = "Next buffer";
          };
          "[b" = {
            action = "<cmd>bprevious<CR>";
            options.desc = "Prev buffer";
          };

          # ── Tabs ──────────────────────────────────────────────────────────
          "]t" = {
            action = "<cmd>tabnext<CR>";
            options.desc = "Next tab";
          };
          "[t" = {
            action = "<cmd>tabprevious<CR>";
            options.desc = "Prev tab";
          };

          # ── Finder (mini.pick) ───────────────────────────────────────────
          "<leader>ff" = {
            action = "<cmd>Pick files<cr>";
            options.desc = "Find files";
          };
          "<leader>fF" = {
            action = "<cmd>Pick files { source = { name = 'All Files', items = function() return MiniPick.builtin.files(nil, {tools={rg={'--hidden','--no-ignore'}}}) end } }<cr>";
            options.desc = "Find files (hidden)";
          };
          "<leader>fw" = {
            action = "<cmd>Pick grep_live<cr>";
            options.desc = "Live grep";
          };

          # ── Git (gitsigns) ────────────────────────────────────────────────
          "<leader>gs" = {
            action = "<cmd>Gitsigns stage_hunk<CR>";
            options.desc = "Stage hunk";
          };
          "<leader>gr" = {
            action = "<cmd>Gitsigns reset_hunk<CR>";
            options.desc = "Reset hunk";
          };
          "<leader>gp" = {
            action = "<cmd>Gitsigns preview_hunk<CR>";
            options.desc = "Preview hunk";
          };
          "]h" = {
            action = "<cmd>Gitsigns next_hunk<CR>";
            options.desc = "Next hunk";
          };
          "[h" = {
            action = "<cmd>Gitsigns prev_hunk<CR>";
            options.desc = "Prev hunk";
          };

          # ── Terminal (toggleterm) ─────────────────────────────────────────
          "<C-'>" = {
            action = "<cmd>ToggleTerm<CR>";
            options.desc = "Toggle terminal";
          };
          "<leader>tf" = {
            action = "<cmd>ToggleTerm direction=float<CR>";
            options.desc = "Floating terminal";
          };
          "<leader>th" = {
            action = "<cmd>ToggleTerm direction=horizontal<CR>";
            options.desc = "Horizontal terminal";
          };
          "<leader>tv" = {
            action = "<cmd>ToggleTerm direction=vertical<CR>";
            options.desc = "Vertical terminal";
          };
          "<leader>tl" = {
            action = "<cmd>ToggleTerm cmd=lazygit<CR>";
            options.desc = "Lazygit";
          };

          # ── Quickfix / location list ──────────────────────────────────────
          "<leader>xq" = {
            action = "<cmd>copen<CR>";
            options.desc = "Open quickfix";
          };
          "<leader>xl" = {
            action = "<cmd>lopen<CR>";
            options.desc = "Open local list";
          };
          "]q" = {
            action = "<cmd>cnext<CR>";
            options.desc = "Next quickfix";
          };
          "[q" = {
            action = "<cmd>cprevious<CR>";
            options.desc = "Prev quickfix";
          };
          "]Q" = {
            action = "<cmd>clast<CR>";
            options.desc = "Last quickfix";
          };
          "[Q" = {
            action = "<cmd>cfirst<CR>";
            options.desc = "First quickfix";
          };
          "]l" = {
            action = "<cmd>lnext<CR>";
            options.desc = "Next local list";
          };
          "[l" = {
            action = "<cmd>lprevious<CR>";
            options.desc = "Prev local list";
          };
          "]L" = {
            action = "<cmd>llast<CR>";
            options.desc = "Last local list";
          };
          "[L" = {
            action = "<cmd>lfirst<CR>";
            options.desc = "First local list";
          };

          # ── UI toggles ────────────────────────────────────────────────────
          "<leader>uw" = {
            action = "<cmd>set wrap!<CR>";
            options.desc = "Toggle wrap";
          };
          "<leader>us" = {
            action = "<cmd>set spell!<CR>";
            options.desc = "Toggle spellcheck";
          };
          "<leader>un" = {
            action = "<cmd>set relativenumber!<CR>";
            options.desc = "Toggle relative numbers";
          };
          "<leader>ud" = {
            action = "<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<CR>";
            options.desc = "Toggle diagnostics";
          };
          "<leader>ub" = {
            action = "<cmd>lua vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'<CR>";
            options.desc = "Toggle background";
          };
          "<leader>uD" = {
            action = "<cmd>lua require('noice').cmd('dismiss')<CR>";
            options.desc = "Dismiss notifications";
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
