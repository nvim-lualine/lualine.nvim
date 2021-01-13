-- =============================================================================
-- Filename: lua/lightline/themes/PaperColor_dark.lua
-- Author: shadman
-- Credit: TKNGUE(lightline)
-- License: MIT License
-- Last Change: 2015-07-27 06:01
-- =============================================================================

local M = {}

local colors = {
  red                    = '#df0000',
  green                  = '#008700',
  blue                   = '#00afaf',
  pink                   = '#afdf00',
  olive                  = '#dfaf5f',
  navy                   = '#df875f',
  orange                 = '#d75f00',
  purple                 = '#8959a8',
  aqua                   = '#3e999f',
  foreground             = '#d0d0d0',
  background             = '#444444',
  window                 = '#efefef',
  status                 = '#c6c6c6',
  error                  = '#5f0000',
  statusline_active_fg   = '#1c1c1c',
  statusline_active_bg   = '#5f8787',
  statusline_inactive_fg = '#c6c6c6',
  statusline_inactive_bg = '#444444',
  visual_fg              = '#000000',
  visual_bg              = '#8787af',
}

M.normal = {
  a = { fg = colors.foreground, bg = colors.background , gui = 'bold', },
  b = { fg = colors.statusline_active_fg, bg = colors.status , },
  c = { fg = colors.statusline_active_fg, bg = colors.statusline_active_bg , }
}

M.insert = {
  a = { fg = colors.background, bg = colors.blue, gui = 'bold', },
}

M.visual = {
  a = { fg = colors.visual_fg, bg = colors.visual_bg , gui = 'bold', },
}

M.replace = {
  a = { fg = colors.background, bg = colors.pink , gui = 'bold', },
}

M.inactive = {
  a = { fg = colors.foreground, bg = colors.background , gui = 'bold', },
  b = { fg = colors.foreground, bg = colors.background , },
  c = { fg = colors.foreground, bg = colors.background , },
}

return M
