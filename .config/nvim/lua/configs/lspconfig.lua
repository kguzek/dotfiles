local nvchad_lspconfig = require "nvchad.configs.lspconfig"

local lua_lsp_plugins_path = "~/.local/share/lua-lsp-plugins"
local hyprland_stub = "/usr/share/hypr/stubs/hl.meta.lua"

-- detect Factorio mod root
local function is_factorio_mod(fname)
  return vim.fs.find("info.json", {
    path = fname,
    upward = true,
  })[1]
end

local function is_hyprland_config(fname)
  return vim.fs.basename(fname) == "hyprland.lua"
end

-- override for conditional Lua libraries
local function on_init(client)
  local fname = vim.api.nvim_buf_get_name(0)

  -- Factorio modding
  if is_factorio_mod(fname) then
    table.insert(client.config.settings.Lua.workspace.library, vim.fn.expand(lua_lsp_plugins_path))
  end

  -- Hyprland config
  if is_hyprland_config(fname) then
    table.insert(client.config.settings.Lua.workspace.library, hyprland_stub)
  end

  nvchad_lspconfig.on_init(client)
end

-- copied from NvChad with modifications
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/configs/lspconfig.lua#L56-L78
local function lua_custom()
  dofile(vim.g.base46_cache .. "lsp")
  require("nvchad.lsp").diagnostic_config()

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      nvchad_lspconfig.on_attach(_, args.buf)
    end,
  })

  local lua_lsp_settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
          vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
          "${3rd}/luv/library",
        },
      },
    },
  }

  -- Use new vim.lsp.config API for Neovim 0.11+
  vim.lsp.config("*", { capabilities = nvchad_lspconfig.capabilities, on_init = nvchad_lspconfig.on_init })
  vim.lsp.config("lua_ls", { settings = lua_lsp_settings, on_init = on_init })
  vim.lsp.enable "lua_ls"
end

lua_custom()

local servers = { "html", "cssls", "ts_ls", "tailwindcss", "ruff", "basedpyright", "clangd" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
