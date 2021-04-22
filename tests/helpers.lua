local luassert = require 'luassert'
local M = {}

M.eq = luassert.are.same
M.neq = luassert.are_not.same
M.meths = setmetatable({}, {
  __index = function(_, key) return vim.api['nvim_' .. key] end
})

return M
