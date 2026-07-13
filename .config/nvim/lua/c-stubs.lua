local M = {}

local function err(msg)
  vim.notify(msg, vim.log.levels.WARN)
end

function M.create_stubs()
  local path = vim.fn.input("Path (without extension): ", "", "file")
  if path == "" then
    return
  end

  if vim.fn.fnamemodify(path, ":t") == "" then
    err("Path has no filename segment (got: " .. path .. ")")
    return
  end

  if vim.fn.isdirectory(path) == 1 then
    err("Path is an existing directory (got: " .. path .. ")")
    return
  end

  local year = os.date "%Y"
  local guard = path:upper():gsub("[./]", "_") .. "_H_"

  local common_content = "// Copyright (c) %s Konrad Guzek\n\n"
  local c_content = (common_content .. '#include "%s.h"\n'):format(year, path)
  local h_content = (common_content .. "#ifndef %s\n#define %s\n\n#endif  // %s\n"):format(year, guard, guard, guard)

  local c_file = path .. ".c"
  local h_file = path .. ".h"

  local c_dir = vim.fn.fnamemodify(c_file, ":h")
  if c_dir ~= "." and vim.fn.isdirectory(c_dir) == 0 then
    vim.fn.mkdir(c_dir, "p")
  end

  vim.fn.writefile(vim.split(c_content, "\n"), c_file)
  vim.fn.writefile(vim.split(h_content, "\n"), h_file)

  vim.cmd("edit " .. c_file)
  vim.cmd("edit " .. h_file)
end

return M
