require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "qmlls",
  "pyright",
  "clangd",
}

vim.lsp.enable(servers)
vim.lsp.enable(servers)
