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
