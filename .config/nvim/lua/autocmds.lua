require "nvchad.autocmds"

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("RestartPrettierd", { clear = true }),
  pattern = "*prettier*",
  callback = function()
    vim.fn.system "prettierd restart"
  end,
})

-- local languages_with_indent_folding = {
--   python = true,
--   sh = true,
--   zsh = true,
-- }
--
-- vim.api.nvim_create_autocmd("FileType", {
--   callback = function(args)
--     if languages_with_indent_folding[args.match] then
--       vim.opt_local.foldmethod = "indent"
--     else
--       if vim.treesitter == nil then
--         vim.opt_local.foldmethod = "syntax"
--       else
--         vim.opt_local.foldmethod = "expr"
--         vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
--       end
--     end
--   end,
-- })
