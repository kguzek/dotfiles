lsp_lines = require "lsp_lines"

return function()
  local new_value = not lsp_lines.toggle()
  vim.diagnostic.config { virtual_text = new_value }
end
