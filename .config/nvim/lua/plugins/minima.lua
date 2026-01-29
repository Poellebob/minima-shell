return {
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            "███    ███ ██ ███    ██ ██ ███    ███  █████  ",
            "████  ████ ██ ████   ██ ██ ████  ████ ██   ██ ",
            "██ ████ ██ ██ ██ ██  ██ ██ ██ ████ ██ ███████ ",
            "██  ██  ██ ██ ██  ██ ██ ██ ██  ██  ██ ██   ██ ",
            "██      ██ ██ ██   ████ ██ ██      ██ ██   ██ ",
          }, "\n"),
        },
      },
    },
  },
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_view_automatic = 1

      vim.g.vimtex_compiler_latexmk = {
        continuous = 1,
        callback = 1,
        build_dir = "",
        options = {
          "-pdf",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-shell-escape",
        },
      }

      vim.keymap.set("n", "-t", "", { desc = "+VimTeX" })
      vim.keymap.set("n", "-tl", "<cmd>VimtexCompile<cr>", { desc = "Compile LaTeX (VimTeX)" })
      vim.keymap.set("n", "-tc", "<cmd>VimtexClean<cr>", { desc = "Clean LaTeX build (VimTeX)" })
      vim.keymap.set("n", "-tv", "<cmd>VimtexView<cr>", { desc = "View PDF (VimTeX)" })
      vim.keymap.set("n", "-tw", "<cmd>VimtexLog<cr>", { desc = "Open LaTeX log (VimTeX)" })
      vim.keymap.set("n", "-ts", "<cmd>VimtexStop<cr>", { desc = "Stop compilation (VimTeX)" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = {
        enable = true,
        disable = { "latex", "tex", "plaintex" },
      },
    },
  },
  {
    "andweeb/presence.nvim",
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = { "saghen/blink.cmp" },
  },
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- optional icons
    },
    keys = {
      -- Main Diffview toggles
      {
        "<leader>dv",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd "DiffviewOpen"
          else
            vim.cmd "DiffviewClose"
          end
        end,
        desc = "Toggle Diffview",
      },
      { "<leader>do", "<cmd>DiffviewOpen<CR>", desc = "Open Diffview" },
      { "<leader>dc", "<cmd>DiffviewClose<CR>", desc = "Close Diffview" },
      { "<leader>dh", "<cmd>DiffviewFileHistory %<CR>", desc = "File History" },
    },
    config = function()
      require("diffview").setup {
        -- You can customize settings here (layouts, icons, etc.)
      }
    end,
  },
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {}

      vim.o.autoread = true

      local opencode = require "opencode"

      --------------------------------------------------------------------
      -- <leader>a — AI / Opencode
      --------------------------------------------------------------------

      -- Ask opencode
      vim.keymap.set(
        { "n", "x" },
        "<leader>aa",
        function() opencode.ask("@this: ", { submit = true }) end,
        { desc = "Opencode: Ask" }
      )

      -- Execute / select action
      vim.keymap.set(
        { "n", "x" },
        "<leader>ae",
        function() opencode.select() end,
        { desc = "Opencode: Execute action" }
      )

      -- Toggle panel
      vim.keymap.set({ "n", "t" }, "<leader>at", function() opencode.toggle() end, { desc = "Opencode: Toggle panel" })

      -- Send motion / visual range
      vim.keymap.set(
        { "n", "x" },
        "<leader>ar",
        function() return opencode.operator "@this " end,
        { expr = true, desc = "Opencode: Send range" }
      )

      -- Send current line
      vim.keymap.set(
        "n",
        "<leader>al",
        function() return opencode.operator "@this " .. "_" end,
        { expr = true, desc = "Opencode: Send line" }
      )

      -- Scroll panel
      vim.keymap.set(
        "n",
        "<leader>ak",
        function() opencode.command "session.half.page.up" end,
        { desc = "Opencode: Scroll up" }
      )

      vim.keymap.set(
        "n",
        "<leader>aj",
        function() opencode.command "session.half.page.down" end,
        { desc = "Opencode: Scroll down" }
      )
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      -- configuration options...
    },
  },
}
