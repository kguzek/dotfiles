local util = require("conform.util")

local function biome_or_prettier(bufnr)
  if util.root_file({ "biome.json" }, bufnr) then
    return { "biome" }
  end
  return { "prettierd" }
end

local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    javascript = biome_or_prettier,
    typescript = biome_or_prettier,
    javascriptreact = biome_or_prettier,
    typescriptreact = biome_or_prettier,
    json = biome_or_prettier,

    css = { "prettierd" },
    html = { "prettierd" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
