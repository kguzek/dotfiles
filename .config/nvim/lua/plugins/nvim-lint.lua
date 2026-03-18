return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require "lint"

    lint.linters_by_ft = {
      cpp = { "cpplint" },
      c = { "cpplint" },
    }

    -- Automatically lint on save
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
      callback = function()
        lint.try_lint()
      end,
    })

    -- Optional: map a key to manually run lint
    -- vim.keymap.set("n", "<leader>l", function() lint.try_lint() end, { desc = "Run linter" })
  end,
}
