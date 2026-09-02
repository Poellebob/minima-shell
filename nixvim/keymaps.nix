{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim = {
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      keymaps = [
        # ── Nice To Have ──────────────────────────────────────────────────────
        {
          mode = "v";
          key = "aa";
          action = "<Esc>gg_vG$";
          options.desc = "Select all";
        }

        # ── Indentation ───────────────────────────────────────────────────────
        {
          mode = "v";
          key = "<Tab>";
          action = ">gv";
          options.desc = "Indent right";
        }
        {
          mode = "v";
          key = "<S-Tab>";
          action = "<gv";
          options.desc = "Indent left";
        }

        # ── Window navigation ─────────────────────────────────────────────────
        {
          mode = "n";
          key = "<C-h>";
          action = "<C-w>h";
          options.desc = "Left window";
        }
        {
          mode = "n";
          key = "<C-j>";
          action = "<C-w>j";
          options.desc = "Down window";
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<C-w>k";
          options.desc = "Up window";
        }
        {
          mode = "n";
          key = "<C-l>";
          action = "<C-w>l";
          options.desc = "Right window";
        }
        {
          mode = "n";
          key = "<C-Up>";
          action = "<cmd>resize +2<CR>";
          options.desc = "Resize up";
        }
        {
          mode = "n";
          key = "<C-Down>";
          action = "<cmd>resize -2<CR>";
          options.desc = "Resize down";
        }
        {
          mode = "n";
          key = "<C-Left>";
          action = "<cmd>vertical resize -2<CR>";
          options.desc = "Resize left";
        }
        {
          mode = "n";
          key = "<C-Right>";
          action = "<cmd>vertical resize +2<CR>";
          options.desc = "Resize right";
        }

        # ── Splits ────────────────────────────────────────────────────────────
        {
          mode = "n";
          key = "\\";
          action = "<cmd>split<CR>";
          options.desc = "Horizontal split";
        }
        {
          mode = "n";
          key = "|";
          action = "<cmd>vsplit<CR>";
          options.desc = "Vertical split";
        }

        # ── File / buffer management ──────────────────────────────────────────
        {
          mode = "n";
          key = "<C-s>";
          action = "<cmd>w!<CR>";
          options.desc = "Force write";
        }
        {
          mode = "n";
          key = "<C-q>";
          action = "<cmd>q!<CR>";
          options.desc = "Force quit";
        }
        {
          mode = "n";
          key = "<leader>n";
          action = "<cmd>enew<CR>";
          options.desc = "New file";
        }
        {
          mode = "n";
          key = "]b";
          action = "<cmd>bnext<CR>";
          options.desc = "Next buffer";
        }
        {
          mode = "n";
          key = "[b";
          action = "<cmd>bprevious<CR>";
          options.desc = "Prev buffer";
        }
        {
          mode = "n";
          key = "<leader>bC";
          action = "<cmd>bufdo bdelete<CR>";
          options.desc = "Close all buffers";
        }

        # ── Tabs ──────────────────────────────────────────────────────────────
        {
          mode = "n";
          key = "]t";
          action = "<cmd>tabnext<CR>";
          options.desc = "Next tab";
        }
        {
          mode = "n";
          key = "[t";
          action = "<cmd>tabprevious<CR>";
          options.desc = "Prev tab";
        }

        # ── Better escape ─────────────────────────────────────────────────────
        {
          mode = "i";
          key = "jj";
          action = "<Esc>";
          options.desc = "Escape";
        }
        {
          mode = "i";
          key = "jk";
          action = "<Esc>";
          options.desc = "Escape";
        }

        # ── Quickfix / location list ──────────────────────────────────────────
        {
          mode = "n";
          key = "<leader>xq";
          action = "<cmd>copen<CR>";
          options.desc = "Open quickfix";
        }
        {
          mode = "n";
          key = "<leader>xl";
          action = "<cmd>lopen<CR>";
          options.desc = "Open local list";
        }
        {
          mode = "n";
          key = "]q";
          action = "<cmd>cnext<CR>";
          options.desc = "Next quickfix";
        }
        {
          mode = "n";
          key = "[q";
          action = "<cmd>cprevious<CR>";
          options.desc = "Prev quickfix";
        }
        {
          mode = "n";
          key = "]Q";
          action = "<cmd>clast<CR>";
          options.desc = "Last quickfix";
        }
        {
          mode = "n";
          key = "[Q";
          action = "<cmd>cfirst<CR>";
          options.desc = "First quickfix";
        }
        {
          mode = "n";
          key = "]l";
          action = "<cmd>lnext<CR>";
          options.desc = "Next local list";
        }
        {
          mode = "n";
          key = "[l";
          action = "<cmd>lprevious<CR>";
          options.desc = "Prev local list";
        }
        {
          mode = "n";
          key = "]L";
          action = "<cmd>llast<CR>";
          options.desc = "Last local list";
        }
        {
          mode = "n";
          key = "[L";
          action = "<cmd>lfirst<CR>";
          options.desc = "First local list";
        }

        # ── UI toggles ────────────────────────────────────────────────────────
        {
          mode = "n";
          key = "<leader>uw";
          action = "<cmd>set wrap!<CR>";
          options.desc = "Toggle wrap";
        }
        {
          mode = "n";
          key = "<leader>us";
          action = "<cmd>set spell!<CR>";
          options.desc = "Toggle spellcheck";
        }
        {
          mode = "n";
          key = "<leader>un";
          action = "<cmd>set relativenumber!<CR>";
          options.desc = "Toggle relative numbers";
        }
        {
          mode = "n";
          key = "<leader>ud";
          action = "<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<CR>";
          options.desc = "Toggle diagnostics";
        }
        {
          mode = "n";
          key = "<leader>ub";
          action = "<cmd>lua vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'<CR>";
          options.desc = "Toggle background";
        }
      ]
      ++ (lib.map (k: {
        mode = k.mode;
        key = k.key;
        action = k.action;
        options.desc = k.desc;
      }) config.minima.vim.keybinds);
    };
  };
}
