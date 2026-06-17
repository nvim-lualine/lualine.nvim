-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()
local bit = require('bit')

-- Initializer
function M:init(options)
  -- Run super()
  M.super.init(self, options)
end

-- Function that runs every time statusline is updated
function M:update_status()
  local curr_filepath = vim.fn.expand('%')
  if curr_filepath == '' then
    return ''
  end

  if not self.options.octal then
    return vim.fn.getfperm(curr_filepath)
  else
    local stat_results = vim.uv.fs_stat(curr_filepath)
    if stat_results == nil then
      return ''
    end
    local bitmask = 0b111111111
    local octal_perm = bit.band(stat_results.mode, bitmask)
    return string.format('o%o', octal_perm)
  end
end

return M
