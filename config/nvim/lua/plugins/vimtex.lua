return {
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

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tex",
      callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "da,en"
      end,
    })
  end,
}
