local map = vim.keymap.set

map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

map({ "n", "x" }, "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "general format file" })

-- tabufline
if require("nvconfig").ui.tabufline.enabled then
  map("n", "<leader>b", "<Nop>", { desc = "Buffers"})

  map("n", "<leader>bp", function()
    require("nvchad.tabufline").prev()
  end, { desc = "buffer goto prev" })

  map("n", "<leader>bc", function()
    require("nvchad.tabufline").close_buffer()
  end, { desc = "buffer close" })
end

-- Comment
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- telescope
map("n", "<leader>f", "<Nop", { desc = "Find" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "Find word" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Find help page" })
map("n", "<leader>fm", "<cmd>Telescope marks<CR>", { desc = "Find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "Find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Find word in current buffer" })
map("n", "<leader>ft", "<cmd>Telescope terms<CR>", { desc = "Find hidden term" })

map("n", "<leader>tt", function()
  require("nvchad.themes").open()
end, { desc = "Find nvchad themes" })

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find file" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "Find all files" }
)

-- Diff
local diffview = require "diffview.lib"

map("n", "<leader>d", "<Nop>", { desc = "Diff" })

map("n", "<leader>dv", function()
  if next(diffview.views) == nil then
    vim.cmd "DiffviewOpen"
  else
    vim.cmd "DiffviewClose"
  end
end, { desc = "Toggle Diffview" })
map("n", "<leader>do", "<cmd>DiffviewOpen<CR>", { desc = "Open Diffview" })
map("n", "<leader>dc", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" })
map("n", "<leader>dh", "<cmd>DiffviewFileHistory %<CR>", { desc = "File History" })

-- terminal
map("n", "<leader>t", "<Nop>", { desc = "Terminal" })
map("t", "<C-x>", "<C-\\><C-n>", { desc = "terminal escape mode" })

map("n", "<leader>tf", function()
  term.new { pos = "float" }
end, { desc = "terminal open floating" })

map("n", "<leader>th", function()
  term.new { pos = "sp" }
end, { desc = "terminal open horizontal" })

map("n", "<leader>tv", function()
  term.new { pos = "vsp" }
end, { desc = "terminal open vertical" })

map({ "n", "t" }, "<leader>tl", function()
  term.toggle {
    pos = "float",
    id = "lazygit",
    cmd = "lazygit",
  }
end, { desc = "terminal toggle lazygit" })

map({ "n", "t" }, "<leader>tn", function()
  term.toggle {
    pos = "float",
    id = "node",
    cmd = "node",
  }
end, { desc = "terminal toggle node" })

map({ "n", "t" }, "<leader>tp", function()
  term.toggle {
    pos = "float",
    id = "python",
    cmd = "python",
  }
end, { desc = "terminal toggle python" })

map({ "n", "t" }, "<leader>tt", function()
  term.toggle {
    pos = "float",
    id = "btm",
    cmd = "btm",
  }
end, { desc = "terminal toggle btm" })

map({ "n", "t" }, "<F7>", function()
  term.toggle { id = "term" }
end, { desc = "terminal toggle current" })

map({ "n", "t" }, "<C-'>", function()
  term.toggle { id = "term" }
end, { desc = "terminal toggle current alt" })

-- Neotree
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Neo-tree toggle" })
map("n", "<leader>o", "<cmd>Neotree focus<CR>", { desc = "Neo-tree focus" })

-- PlatformIO
map("n", "-p", "", { desc = "PlatformIO" })
map("n", "-pd", "<cmd>!pio run -t compiledb<CR>", { desc = "Make pio compiledb" })
map("n", "-pu", "<cmd>!pio run -t upload<CR>", { desc = "Upload pio project" })
map("n", "-pm", "<cmd>!pio run<CR>", { desc = "Make pio project" })
map("n", "-pc", "<cmd>!pio run -t clean<CR>", { desc = "Clean pio project" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "da,en"
  end,
})

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
