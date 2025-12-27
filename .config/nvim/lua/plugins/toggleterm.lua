return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm" },
  config = function()
    require("toggleterm").setup {
      size = 16,   -- default height
      -- open_mapping = [[<c-\>]], -- Ctrl+\ toggles
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      start_in_insert = true,
      persist_size = true,        -- keeps terminal size
      direction = "horizontal",   -- can also be 'vertical' or 'float'
    }
  end
}
