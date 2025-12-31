vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

vim.keymap.set("n", "-m", "<cmd>!make<cr>", {desc = "Run Make"})

vim.keymap.set("n", "-p", "", {desc = "PlatformIO"})
vim.keymap.set("n", "-pd", "<cmd>!pio run -t cmpiledb<CR>", {desc = "Make pio compiledb"})
vim.keymap.set("n", "-pu", "<cmd>!pio run -t upload<CR>", {desc = "Upload pio project"})
vim.keymap.set("n", "-pm", "<cmd>!pio run<CR>", {desc = "Make pio project"})
vim.keymap.set("n", "-pc", "<cmd>!pio run -t clean<CR>", {desc = "Clean pio project"})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "da,en"
  end,
})

