-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local lualine_require = require('lualine_require')
local M = lualine_require.require('lualine.component'):extend()

local default_options = {
  -- Show '[BOM]' when the file has a byte-order mark
  show_bomb = false,
}

function M:init(options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
end

function M:update_status()
  local show_bomb = self.options.show_bomb

  local result = vim.opt.fileencoding:get()

  if not show_bomb then
    return result
  end

  if vim.opt.bomb:get() then
    result = result .. ' [BOM]'
  end

  return result
end

return M
