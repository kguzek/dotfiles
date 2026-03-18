local prettier = { "prettierd" }

local BIOME_CONFIG_FILENAMES = { "biome.json", "biome.jsonc" }

local function has_biome(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return false
  end

  local start_dir = vim.fs.dirname(bufname)

  local root = vim.fs.root(start_dir, { unpack(BIOME_CONFIG_FILENAMES), ".git" })
  if not root then
    return false
  end

  for _, file in ipairs(BIOME_CONFIG_FILENAMES) do
    if vim.loop.fs_stat(root .. "/" .. file) then
      return true
    end
  end

  return false
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
    yaml = prettier,

    python = {
      "ruff_fix", -- To fix auto-fixable lint errors.
      "ruff_format", -- To run the Ruff formatter.
      "ruff_organize_imports", -- To organize the imports.
    },

    c = { "clang-format" },
    cpp = { "clang-format" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
