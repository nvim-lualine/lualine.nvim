-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local M = {}

-- Works as a decorator to expand set_lualine_theme functions
-- functionality at runtime .
function M.expand_set_theme(func)
  -- execute a local version of global function to not get in a inf recurtion
  local set_theme = _G.set_lualine_theme
  _G.set_lualine_theme = function()
    set_theme()
    func()
  end
end

return M
