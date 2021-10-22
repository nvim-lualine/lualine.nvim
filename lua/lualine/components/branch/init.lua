-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()
local require = require('lualine_require').require
local git_branch = require 'lualine.components.branch.git_branch'

-- Initilizer
M.init = function(self, options)
  M.super.init(self, options)
  if not self.options.icon then
    self.options.icon = '' -- e0a0
  end
  git_branch.init()
end

M.update_status = function(_, is_focused)
  return git_branch.get_branch((not is_focused and vim.fn.bufnr()))
end

return M
