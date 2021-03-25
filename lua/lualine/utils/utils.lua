-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = {}

-- Note for now only works for termguicolors scope can be background or foreground
function M.extract_highlight_colors(color_group, scope)
  if vim.fn.hlexists(color_group) == 0 then return nil end
  local gui_colors = vim.api.nvim_get_hl_by_name(color_group, true)
  local cterm_colors = vim.api.nvim_get_hl_by_name(color_group, false)
  local color = {
    ctermfg = cterm_colors.foreground,
    ctermbg = cterm_colors.background
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

-- table to store the highlight names created by lualine
M.loaded_highlights = {}

-- sets loaded_highlights table
function M.save_highlight(highlight_name, highlight_args)
  M.loaded_highlights[highlight_name] = highlight_args
end

function M.reload_highlights()
  local highlight = require('lualine.highlight')
  for _, highlight_args in pairs(M.loaded_highlights) do
     highlight.highlight(unpack(highlight_args))
  end
end

-- determine if an highlight exist and isn't cleared
function M.highlight_exists(highlight_name)
  return M.loaded_highlights[highlight_name] and true or false
end

return M
