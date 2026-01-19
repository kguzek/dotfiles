local util = require "conform.util"

local prettier = { "prettierd" }

local function has_biome(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return false
  end

  local start_dir = vim.fs.dirname(bufname)

  local root = vim.fs.root(start_dir, { "biome.json", ".git" })
  if not root then
    return false
  end

  return vim.loop.fs_stat(root .. "/biome.json") ~= nil
end

local function biome_or_prettier(bufnr)
  if has_biome(bufnr) then
    return { "biome" }
  end
  return prettier
end

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
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
