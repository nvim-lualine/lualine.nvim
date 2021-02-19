-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local M = {}

-- Works as a decorator to expand set_lualine_theme functions
-- functionality at runtime .
function M.expand_set_theme(func)
  -- execute a local version of global function to not get in a inf recurtion
  local set_theme = _G.lualine_set_theme
  _G.lualine_set_theme = function()
    set_theme()
    func()
  end
end

-- Note for now only works for termguicolors scope can be background or foreground
function M.extract_highlight_colors(color_group, scope)
  if not M.highlight_exists(color_group) then return nil end
  local gui_colors = vim.api.nvim_get_hl_by_name(color_group, true)
  local cterm_colors = vim.api.nvim_get_hl_by_name(color_group, false)
  local color = {
    ctermfg = cterm_colors.foreground,
    ctermbg = cterm_colors.background,
  }
  if gui_colors.background then
    color.guibg = string.format('#%06x', gui_colors.background)
    gui_colors.background = nil
  end
  if gui_colors.foreground then
    color.guifg = string.format('#%06x', gui_colors.foreground)
    gui_colors.foreground = nil
  end
  cterm_colors.background = nil
  cterm_colors.foreground = nil
  color = vim.tbl_extend('keep', color, gui_colors, cterm_colors)
  if scope then return color[scope] end
  return color
end

-- determine if an highlight exist and isn't cleared
function M.highlight_exists(highlight_name)
  local ok, result = pcall(vim.api.nvim_exec, 'highlight '..highlight_name, true)
  if not ok then return false end
  return result:find('xxx cleared') == nil
end

return M
