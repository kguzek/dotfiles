require "nvchad.mappings"

local map = vim.keymap.set

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Telescope
map("n", "<C-p>", "<cmd>Telescope git_files<CR>", { desc = "Telescope git files" })
map(
  "n",
  "<leader>fg",
  "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
  { desc = "Telescope live grep with arguments" }
)

map("n", "<leader>o", "o<Esc>k", { desc = "Blank line below" })
map("n", "<leader>O", "O<Esc>j", { desc = "Blank line above" })

vim.api.nvim_del_keymap("n", "<C-n>")
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

map({ "n", "t" }, "<C-n>", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Toggle terminal" })
map(
  { "n", "t" },
  "<C-n>k",
  "<cmd>ToggleTerm 9 size=80 direction=vertical name=Chat<CR>",
  { desc = "Toggle chat terminal" }
)
for i = 1, 9 do
  map("n", "<C-n>" .. i, "<cmd>ToggleTerm " .. i .. " direction=horizontal<CR>", { desc = "Open terminal" })
  map("t", "<C-n>" .. i, "<C-\\><C-n><cmd>ToggleTerm " .. i .. "<CR>", { desc = "Close terminal" })
end

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- C source/header stubs
map("n", "<leader>cs", require("c-stubs").create_stubs, { desc = "Create C source/header stubs" })

-- LSP error lines
map("", "<leader>l", require "toggle-error-lines", { desc = "Toggle lsp_lines" })
map("", "<leader>;", vim.diagnostic.open_float, { desc = "Open error diagnostic float" })
