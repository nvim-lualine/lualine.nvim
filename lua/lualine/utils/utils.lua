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

-- Note for now only works for termguicolors scope can be background or foreground
function M.extract_highlight_colors(color_group, scope)
  local color = string.format('#%06x', vim.api.nvim_get_hl_by_name(color_group, true)[scope])
  return color or nil
end

return M
