return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
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
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          require("snacks").dashboard.open()
        end
      end,
    })
  end,
}
