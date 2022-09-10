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
  return filename ~= '' and vim.bo.buftype == '' and vim.fn.filereadable(filename) == 0
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
    data = shorten_path(data, path_separator, estimated_space_available)
  end

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
