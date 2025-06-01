-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()

local modules = require('lualine_require').lazy_require {
  utils = 'lualine.utils.utils',
}

local default_options = {
  symbols = {
    modified = '[+]',
    readonly = '[-]',
    unnamed = '[No Name]',
    newfile = '[New]',
  },
  file_status = true,
  newfile_status = false,
  path = 0,
  shorting_target = 40,
}

local function is_new_file()
  local filename = vim.fn.expand('%')
  return filename ~= ''
    and filename:match('^%a+://') == nil
    and vim.bo.buftype == ''
    and vim.fn.filereadable(filename) == 0
end

---shortens path by turning apple/orange -> a/orange
---@param path string
---@param sep string path separator
---@param max_len integer maximum length of the full filename string
---@return string
local function shorten_path(path, sep, max_len)
  local len = #path
  if len <= max_len then
    return path
  end

  local segments = vim.split(path, sep)
  for idx = 1, #segments - 1 do
    if len <= max_len then
      break
    end

    local segment = segments[idx]
    local shortened = segment:sub(1, vim.startswith(segment, '.') and 2 or 1)
    segments[idx] = shortened
    len = len - (#segment - #shortened)
  end

  return table.concat(segments, sep)
end

local function filename_and_parent(path, sep)
  local segments = vim.split(path, sep)
  if #segments == 0 then
    return path
  elseif #segments == 1 then
    return segments[#segments]
  else
    return table.concat({ segments[#segments - 1], segments[#segments] }, sep)
  end
end

-- return the absolute path of root of the git repo
local function git_root()
  local handle = io.popen('git rev-parse --show-toplevel 2>&1')
  if not handle then
    return '', 1 -- failed to open process
  end

  local result = handle:read('*a')
  local ok, _, exit_code = handle:close()

  -- Remove trailing newline
  result = result:gsub('%s+$', '')

  -- If handle:close() returns false, use exit_code = 1
  if not ok then
    return result, exit_code or 1
  end

  return result, 0
end

-- remove all path components from '/' down to the parent of the git repo
local function remove_git_root_parent(git_root_parent, file_path)
  local result = {}
  for i = #git_root_parent + 1, #file_path do
    table.insert(result, file_path[i])
  end

  return result
end

-- return the relative path of the file, including the git repo;
-- if it's not a git repo, do the same as filename_and_parent (options.path == 4)
local function path_with_gitroot(path, sep)
  local segments = vim.split(path, sep)
  if #segments == 0 then
    return path
  elseif #segments == 1 then
    return segments[#segments]
  else
    local git_root_path, status = git_root()
    if status ~= 0 then
      -- not a git repo; act just like path type 4
      return table.concat({ segments[#segments - 1], segments[#segments] }, sep)
    else
      -- remove the git repo path from the path, but first split it
      local git_root_path_segments = {}
      git_root_path_segments = vim.split(git_root_path, sep)
      -- remove the last component of the git root path which is the repo name
      table.remove(git_root_path_segments, nil)
      local final_segments = remove_git_root_parent(git_root_path_segments, segments)
      -- rebuild the relative path from the git root, which should include the repo name
      return table.concat(final_segments, sep)
    end
  end
end

M.init = function(self, options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
end

M.update_status = function(self)
  local path_separator = package.config:sub(1, 1)
  local data
  if self.options.path == 1 then
    -- relative path
    data = vim.fn.expand('%:~:.')
  elseif self.options.path == 2 then
    -- absolute path
    data = vim.fn.expand('%:p')
  elseif self.options.path == 3 then
    -- absolute path, with tilde
    data = vim.fn.expand('%:p:~')
  elseif self.options.path == 4 then
    -- filename and immediate parent
    data = filename_and_parent(vim.fn.expand('%:p:~'), path_separator)
  elseif self.options.path == 5 then
    -- path from top of git repo, including the git repo name and the file name;
    -- if not in a git repo, default to options.path = 4 as above
    data = path_with_gitroot(vim.fn.expand('%:p'), path_separator)
  else
    -- just filename
    data = vim.fn.expand('%:t')
  end

  if data == '' then
    data = self.options.symbols.unnamed
  end

  if self.options.shorting_target ~= 0 then
    local windwidth = self.options.globalstatus and vim.go.columns or vim.fn.winwidth(0)
    local estimated_space_available = windwidth - self.options.shorting_target

    data = shorten_path(data, path_separator, estimated_space_available)
  end

  data = modules.utils.stl_escape(data)

  local symbols = {}
  if self.options.file_status then
    if vim.bo.modified then
      table.insert(symbols, self.options.symbols.modified)
    end
    if vim.bo.modifiable == false or vim.bo.readonly == true then
      table.insert(symbols, self.options.symbols.readonly)
    end
  end

  if self.options.newfile_status and is_new_file() then
    table.insert(symbols, self.options.symbols.newfile)
  end

  return data .. (#symbols > 0 and ' ' .. table.concat(symbols, '') or '')
end

return M
