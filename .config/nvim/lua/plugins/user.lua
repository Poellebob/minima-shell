return {
  {
    vim.keymap.set("n", "-m", "<cmd>!make<cr>", {desc = "Run Make"}),
    
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tex",
      callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "da,en"
      end,
    })
  },

  "andweeb/presence.nvim",
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
          }, "\n")
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
        build_dir = '',
        options = {
          '-pdf',
          '-verbose',
          '-file-line-error',
          '-synctex=1',
          '-interaction=nonstopmode',
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
}
