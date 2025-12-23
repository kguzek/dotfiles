return {
  {
    "windwp/nvim-ts-autotag",
    -- ft = { "html", "xml", "javascriptreact", "typescriptreact", "vue", "svelte" },
    -- event = "InsertEnter", -- lazy-load when entering insert mode
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
        -- per_filetype = {
        --   ["html"] = {
        --     enable_close = false,
        --   },
        -- },
      })
    end
  }
}
