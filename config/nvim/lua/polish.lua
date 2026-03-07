require("lspconfig").qmlls.setup {}

local Terminal = require("toggleterm.terminal").Terminal

local gemini = Terminal:new({
  cmd = "gemini",
  direction = "float",
  hidden = true,
  float_opts = {
    border = "rounded",
  },
})

function gemini:toggle()
  if self:is_open() then
    self:close()
  else
    self:open()
  end
end

vim.keymap.set("n", "<leader>tg", function() gemini:toggle() end, { desc = "Toggle Gemini terminal" })

