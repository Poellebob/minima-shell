return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    vim.g.opencode_opts = {}

    vim.o.autoread = true

    local opencode = require "opencode"

    vim.keymap.set(
      { "n", "x" },
      "<leader>aa",
      function() opencode.ask("@this: ", { submit = true }) end,
      { desc = "Opencode: Ask" }
    )

    vim.keymap.set(
      { "n", "x" },
      "<leader>ae",
      function() opencode.select() end,
      { desc = "Opencode: Execute action" }
    )

    vim.keymap.set({ "n", "t" }, "<leader>at", function() opencode.toggle() end, { desc = "Opencode: Toggle panel" })

    vim.keymap.set(
      { "n", "x" },
      "<leader>ar",
      function() return opencode.operator "@this " end,
      { expr = true, desc = "Opencode: Send range" }
    )

    vim.keymap.set(
      "n",
      "<leader>al",
      function() return opencode.operator "@this " .. "_" end,
      { expr = true, desc = "Opencode: Send line" }
    )

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
}
