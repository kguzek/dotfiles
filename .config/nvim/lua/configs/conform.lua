local prettier = { "prettierd" }
local biome_or_prettier = { "prettierd", "biome" }

local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    javascript = biome_or_prettier,
    typescript = biome_or_prettier,
    javascriptreact = biome_or_prettier,
    typescriptreact = biome_or_prettier,
    json = biome_or_prettier,

    css = prettier,
    html = prettier,
    markdown = prettier,

    python = {
      "ruff_fix", -- To fix auto-fixable lint errors.
      "ruff_format", -- To run the Ruff formatter.
      "ruff_organize_imports", -- To organize the imports.
    },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
