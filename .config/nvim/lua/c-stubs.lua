local M = {}

local function err(msg)
  vim.notify(msg, vim.log.levels.WARN)
end

local function tracked_dirs()
  local ok, result = pcall(vim.fn.systemlist, "git ls-files --cached --others --exclude-standard 2>/dev/null")
  if not ok or vim.v.shell_error ~= 0 then
    return nil
  end
  local dirs, seen = {}, {}
  for _, file in ipairs(result) do
    local dir = vim.fn.fnamemodify(file, ":h")
    if dir ~= "." and not seen[dir] then
      seen[dir] = true
      table.insert(dirs, dir)
    end
  end
  table.sort(dirs)
  return dirs
end

local function all_dirs()
  local result = vim.fn.systemlist "find . -mindepth 1 -type d 2>/dev/null | sort"
  if vim.v.shell_error ~= 0 then
    return {}
  end
  local dirs = {}
  for _, d in ipairs(result) do
    table.insert(dirs, d:gsub("^%./", ""))
  end
  return dirs
end

local function do_create(path)
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

  local existing = {}
  if vim.fn.filereadable(c_file) == 1 then
    table.insert(existing, c_file)
  end
  if vim.fn.filereadable(h_file) == 1 then
    table.insert(existing, h_file)
  end
  if #existing > 0 then
    err("Files already exist:\n" .. table.concat(existing, "\n"))
    return
  end

  local c_dir = vim.fn.fnamemodify(c_file, ":h")
  if c_dir ~= "." and vim.fn.isdirectory(c_dir) == 0 then
    vim.fn.mkdir(c_dir, "p")
  end

  vim.fn.writefile(vim.split(c_content, "\n"), c_file)
  vim.fn.writefile(vim.split(h_content, "\n"), h_file)

  vim.cmd("edit " .. c_file)
  vim.cmd("edit " .. h_file)
end

function M.create_stubs()
  local dirs = tracked_dirs()
  if dirs == nil then
    dirs = all_dirs()
  end

  if #dirs == 0 or dirs[1] ~= "." then
    table.insert(dirs, 1, ".")
  end

  if #dirs == 1 then
    do_create(vim.fn.input "Path (without extension): ")
    return
  end

  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  pickers
    .new(conf, {
      prompt_title = "Select directory",
      finder = finders.new_table { results = dirs },
      sorter = conf.generic_sorter(conf),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if not selection then
            return
          end
          local dir = selection[1]
          local basename = vim.fn.input "Filename (without extension): "
          local path = dir == "." and basename or (dir .. "/" .. basename)
          do_create(path)
        end)
        return true
      end,
    })
    :find()
end

return M
