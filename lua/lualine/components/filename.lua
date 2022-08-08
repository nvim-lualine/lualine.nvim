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

---counts how many times pattern occur in base ( used for counting path-sep )
---@param base string
---@param pattern string
---@return number
local function count(base, pattern)
  return select(2, string.gsub(base, pattern, ''))
end

local function is_new_file()
  local filename = vim.fn.expand('%')
  return vim.bo.buftype == '' and vim.fn.filereadable(filename) == 0
end

---shortens path by turning apple/orange -> a/orange
---@param path string
---@param sep string path separator
---@return string
local function shorten_path(path, sep)
  -- ('([^/])[^/]+%/', '%1/', 1)
  return path:gsub(string.format('([^%s])[^%s]+%%%s', sep, sep, sep), '%1' .. sep, 1)
end

M.init = function(self, options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
end

M.update_status = function(self)
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
  else
    -- just filename
    data = vim.fn.expand('%:t')
  end

  data = modules.utils.stl_escape(data)

  if data == '' then
    data = self.options.symbols.unnamed
  end

  if self.options.shorting_target ~= 0 then
    local windwidth = self.options.globalstatus and vim.go.columns or vim.fn.winwidth(0)
    local estimated_space_available = windwidth - self.options.shorting_target

    local path_separator = package.config:sub(1, 1)
    for _ = 0, count(data, path_separator) do
      if windwidth <= 84 or #data > estimated_space_available then
        data = shorten_path(data, path_separator)
      end
    end
  end

  if self.options.file_status then
    if vim.bo.modified then
      data = data .. self.options.symbols.modified
    end
    if vim.bo.modifiable == false or vim.bo.readonly == true then
      data = data .. self.options.symbols.readonly
    end
  end

  if self.options.newfile_status and is_new_file() then
    data = data .. self.options.symbols.newfile
  end
  return data
end

return M
