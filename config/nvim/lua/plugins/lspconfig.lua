return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("qmlls", {
        cmd = { "qmlls6" },
        filetypes = { "qml", "qmljs" },
      })

      vim.lsp.enable("qmlls")
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
}
