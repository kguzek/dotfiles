require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<C-p>", "<cmd>Telescope git_files<CR>", { desc = "Telescope git files" })

map("n", "<leader>o", "o<Esc>k", { desc = "Blank line below" })
map("n", "<leader>O", "O<Esc>k", { desc = "Blank line above" })

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
