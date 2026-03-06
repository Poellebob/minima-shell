{ config, lib, ... }:
{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim = {
      enable = true;
      colorschemes.${config.minima.vim.theme.name} = {
        enable = true;
        settings.flavour = config.minima.vim.theme.flavour;
      };
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };
      opts = {
        tabstop = 2;
        shiftwidth = 2;
        softtabstop = 2;
        expandtab = true;
        clipboard = "unnamedplus";
        number = true;
        relativenumber = true;
        undofile = true;
        ignorecase = true;
        smartcase = true;
        splitright = true;
        splitbelow = true;
        scrolloff = 8;
        updatetime = 250;
      };
      keymaps = [
        # ── Neo-tree ──────────────────────────────────────────────────────────
        { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<CR>";        options.desc = "Neo-tree toggle"; }
        { mode = "n"; key = "<leader>o"; action = "<cmd>Neotree focus<CR>";         options.desc = "Neo-tree focus"; }

        # ── Window navigation ─────────────────────────────────────────────────
        { mode = "n"; key = "<C-h>";     action = "<C-w>h";                         options.desc = "Left window"; }
        { mode = "n"; key = "<C-j>";     action = "<C-w>j";                         options.desc = "Down window"; }
        { mode = "n"; key = "<C-k>";     action = "<C-w>k";                         options.desc = "Up window"; }
        { mode = "n"; key = "<C-l>";     action = "<C-w>l";                         options.desc = "Right window"; }
        { mode = "n"; key = "<C-Up>";    action = "<cmd>resize +2<CR>";             options.desc = "Resize up"; }
        { mode = "n"; key = "<C-Down>";  action = "<cmd>resize -2<CR>";             options.desc = "Resize down"; }
        { mode = "n"; key = "<C-Left>";  action = "<cmd>vertical resize -2<CR>";   options.desc = "Resize left"; }
        { mode = "n"; key = "<C-Right>"; action = "<cmd>vertical resize +2<CR>";   options.desc = "Resize right"; }

        # ── Splits ────────────────────────────────────────────────────────────
        { mode = "n"; key = "\\";        action = "<cmd>split<CR>";                 options.desc = "Horizontal split"; }
        { mode = "n"; key = "|";         action = "<cmd>vsplit<CR>";                options.desc = "Vertical split"; }

        # ── File / buffer management ──────────────────────────────────────────
        { mode = "n"; key = "<C-s>";      action = "<cmd>w!<CR>";                        options.desc = "Force write"; }
        { mode = "n"; key = "<C-q>";      action = "<cmd>q!<CR>";                        options.desc = "Force quit"; }
        { mode = "n"; key = "<leader>n";  action = "<cmd>enew<CR>";                      options.desc = "New file"; }
        { mode = "n"; key = "<leader>c";  action = "<cmd>bdelete<CR>";                   options.desc = "Close buffer"; }
        { mode = "n"; key = "]b";         action = "<cmd>bnext<CR>";                     options.desc = "Next buffer"; }
        { mode = "n"; key = "[b";         action = "<cmd>bprevious<CR>";                 options.desc = "Prev buffer"; }
        { mode = "n"; key = ">b";         action = "<cmd>BufferLineMoveNext<CR>";        options.desc = "Move buffer right"; }
        { mode = "n"; key = "<b";         action = "<cmd>BufferLineMovePrev<CR>";        options.desc = "Move buffer left"; }
        { mode = "n"; key = "<leader>bc"; action = "<cmd>BufferLineCloseOthers<CR>";     options.desc = "Close other buffers"; }
        { mode = "n"; key = "<leader>bC"; action = "<cmd>bufdo bdelete<CR>";             options.desc = "Close all buffers"; }
        { mode = "n"; key = "<leader>bp"; action = "<cmd>BufferLineCyclePrev<CR>";       options.desc = "Prev buffer"; }
        { mode = "n"; key = "<leader>bl"; action = "<cmd>BufferLineCloseLeft<CR>";       options.desc = "Close buffers left"; }
        { mode = "n"; key = "<leader>br"; action = "<cmd>BufferLineCloseRight<CR>";      options.desc = "Close buffers right"; }

        # ── Tabs ──────────────────────────────────────────────────────────────
        { mode = "n"; key = "]t"; action = "<cmd>tabnext<CR>";     options.desc = "Next tab"; }
        { mode = "n"; key = "[t"; action = "<cmd>tabprevious<CR>"; options.desc = "Prev tab"; }

        # ── Better escape ─────────────────────────────────────────────────────
        { mode = "i"; key = "jj"; action = "<Esc>"; options.desc = "Escape"; }
        { mode = "i"; key = "jk"; action = "<Esc>"; options.desc = "Escape"; }

        # ── Dashboard ─────────────────────────────────────────────────────────
        { mode = "n"; key = "<leader>h"; action = "<cmd>lua Snacks.dashboard()<CR>"; options.desc = "Dashboard"; }

        # ── Telescope / finder ────────────────────────────────────────────────
        { mode = "n"; key = "<leader>ff";    action = "<cmd>Telescope find_files<CR>";                                    options.desc = "Find files"; }
        { mode = "n"; key = "<leader>fF";    action = "<cmd>Telescope find_files hidden=true<CR>";                        options.desc = "Find files (hidden)"; }
        { mode = "n"; key = "<leader>fw";    action = "<cmd>Telescope live_grep<CR>";                                     options.desc = "Live grep"; }
        { mode = "n"; key = "<leader>fb";    action = "<cmd>Telescope buffers<CR>";                                       options.desc = "Find buffers"; }
        { mode = "n"; key = "<leader>fh";    action = "<cmd>Telescope help_tags<CR>";                                     options.desc = "Help tags"; }
        { mode = "n"; key = "<leader>fk";    action = "<cmd>Telescope keymaps<CR>";                                       options.desc = "Keymaps"; }
        { mode = "n"; key = "<leader>fo";    action = "<cmd>Telescope oldfiles<CR>";                                      options.desc = "Recent files"; }
        { mode = "n"; key = "<leader>fr";    action = "<cmd>Telescope registers<CR>";                                     options.desc = "Registers"; }
        { mode = "n"; key = "<leader>fC";    action = "<cmd>Telescope commands<CR>";                                      options.desc = "Commands"; }
        { mode = "n"; key = "<leader>fn";    action = "<cmd>lua require('telescope').extensions.notify.notify()<CR>";     options.desc = "Notifications"; }
        { mode = "n"; key = "<leader>f<CR>"; action = "<cmd>Telescope resume<CR>";                                        options.desc = "Resume search"; }

        # ── Git (telescope pickers) ───────────────────────────────────────────
        { mode = "n"; key = "<leader>gb"; action = "<cmd>Telescope git_branches<CR>";  options.desc = "Git branches"; }
        { mode = "n"; key = "<leader>gc"; action = "<cmd>Telescope git_commits<CR>";   options.desc = "Git commits (repo)"; }
        { mode = "n"; key = "<leader>gC"; action = "<cmd>Telescope git_bcommits<CR>";  options.desc = "Git commits (file)"; }
        { mode = "n"; key = "<leader>gt"; action = "<cmd>Telescope git_status<CR>";    options.desc = "Git status"; }

        # ── Git (gitsigns) ────────────────────────────────────────────────────
        { mode = "n"; key = "<leader>gs"; action = "<cmd>Gitsigns stage_hunk<CR>";   options.desc = "Stage hunk"; }
        { mode = "n"; key = "<leader>gr"; action = "<cmd>Gitsigns reset_hunk<CR>";   options.desc = "Reset hunk"; }
        { mode = "n"; key = "<leader>gp"; action = "<cmd>Gitsigns preview_hunk<CR>"; options.desc = "Preview hunk"; }
        { mode = "n"; key = "]h";         action = "<cmd>Gitsigns next_hunk<CR>";    options.desc = "Next hunk"; }
        { mode = "n"; key = "[h";         action = "<cmd>Gitsigns prev_hunk<CR>";    options.desc = "Prev hunk"; }

        # ── Terminal (snacks) ─────────────────────────────────────────────────
        { mode = [ "n" "t" ]; key = "<F7>";        action = "<cmd>lua Snacks.terminal.toggle()<CR>";                                        options.desc = "Toggle terminal"; }
        { mode = "n";          key = "<leader>tf"; action = "<cmd>lua Snacks.terminal.toggle(nil, { win = { style = 'float' } })<CR>";      options.desc = "Floating terminal"; }
        { mode = "n";          key = "<leader>th"; action = "<cmd>lua Snacks.terminal.toggle(nil, { win = { position = 'bottom' } })<CR>";  options.desc = "Horizontal terminal"; }
        { mode = "n";          key = "<leader>tv"; action = "<cmd>lua Snacks.terminal.toggle(nil, { win = { position = 'right' } })<CR>";   options.desc = "Vertical terminal"; }
        { mode = "n";          key = "<leader>tl"; action = "<cmd>lua Snacks.terminal.toggle('lazygit')<CR>";                               options.desc = "Lazygit"; }

        # ── Quickfix / location list ──────────────────────────────────────────
        { mode = "n"; key = "<leader>xq"; action = "<cmd>copen<CR>";     options.desc = "Open quickfix"; }
        { mode = "n"; key = "<leader>xl"; action = "<cmd>lopen<CR>";     options.desc = "Open local list"; }
        { mode = "n"; key = "]q";         action = "<cmd>cnext<CR>";     options.desc = "Next quickfix"; }
        { mode = "n"; key = "[q";         action = "<cmd>cprevious<CR>"; options.desc = "Prev quickfix"; }
        { mode = "n"; key = "]Q";         action = "<cmd>clast<CR>";     options.desc = "Last quickfix"; }
        { mode = "n"; key = "[Q";         action = "<cmd>cfirst<CR>";    options.desc = "First quickfix"; }
        { mode = "n"; key = "]l";         action = "<cmd>lnext<CR>";     options.desc = "Next local list"; }
        { mode = "n"; key = "[l";         action = "<cmd>lprevious<CR>"; options.desc = "Prev local list"; }
        { mode = "n"; key = "]L";         action = "<cmd>llast<CR>";     options.desc = "Last local list"; }
        { mode = "n"; key = "[L";         action = "<cmd>lfirst<CR>";    options.desc = "First local list"; }

        # ── Undotree ──────────────────────────────────────────────────────────
        { mode = "n"; key = "<leader>fu"; action = "<cmd>UndotreeToggle<CR>"; options.desc = "Undo history"; }

        # ── UI toggles ────────────────────────────────────────────────────────
        { mode = "n"; key = "<leader>uw"; action = "<cmd>set wrap!<CR>";                                                           options.desc = "Toggle wrap"; }
        { mode = "n"; key = "<leader>us"; action = "<cmd>set spell!<CR>";                                                          options.desc = "Toggle spellcheck"; }
        { mode = "n"; key = "<leader>un"; action = "<cmd>set relativenumber!<CR>";                                                 options.desc = "Toggle relative numbers"; }
        { mode = "n"; key = "<leader>ud"; action = "<cmd>lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<CR>";          options.desc = "Toggle diagnostics"; }
        { mode = "n"; key = "<leader>ub"; action = "<cmd>lua vim.o.background = vim.o.background == 'dark' and 'light' or 'dark'<CR>"; options.desc = "Toggle background"; }
        { mode = "n"; key = "<leader>uD"; action = "<cmd>lua Snacks.notifier.hide()<CR>";                                          options.desc = "Dismiss notifications"; }

        # ── Commenting ────────────────────────────────────────────────────────
        { mode = "n"; key = "<leader>/"; action = "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>";               options.desc = "Toggle comment"; }
        { mode = "v"; key = "<leader>/"; action = "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>"; options.desc = "Toggle comment"; }
      ] ++ map (k: {
        mode = k.mode;
        key = k.key;
        action = k.action;
        options.desc = k.desc;
      }) config.minima.vim.keybinds;
      autoCmd = map (a: {
        event = a.event;
        pattern = a.pattern;
        command = a.command;
        desc = a.desc;
      }) config.minima.vim.autocmd;
      plugins = {
        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
            auto_install = true;
          };
        };
        gitsigns.enable = true;
        undotree.enable = true;
        nvim-autopairs.enable = true;
        comment.enable = true;
        which-key.enable = true;
        cmp = {
          enable = true;
          settings = {
            sources = [
              { name = "nvim_lsp"; }
              { name = "buffer"; }
              { name = "path"; }
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
      } // config.minima.vim.plugins;
    };
  };
}
