-- =============================================================================
-- Filename: lua/lualine/themes/16color.lua
-- Author: shadman 
-- Credit itchyny, jackno (lightline)
-- License: MIT License
-- =============================================================================

local M = {}

local colors = {
  black   = { '#000000', 0 },
  maroon  = { '#800000', 1 },
  green   = { '#008000', 2 },
  olive   = { '#808000', 3 },
  navy    = { '#000080', 4 },
  purple  = { '#800080', 5 },
  teal    = { '#008080', 6 },
  silver  = { '#c0c0c0', 7 },
  gray    = { '#808080', 8},
  red     = { '#ff0000', 9 },
  lime    = { '#00ff00', 10 },
  yellow  = { '#ffff00', 11 },
  blue    = { '#0000ff', 12 },
  fuchsia = { '#ff00ff', 13 },
  aqua    = { '#00ffff', 14 },
  white   = { '#ffffff', 15 },
}

M.normal = {
  a = { fg = colors.white, bg = colors.blue , gui = 'bold', },
  b = { fg = colors.white, bg = colors.gray , },
  c = { fg = colors.silver, bg = colors.black , }
}

M.insert = {
  a = { fg = colors.white, bg = colors.green , gui = 'bold', },
}


M.visual = {
  a = { fg = colors.white, bg = colors.purple , gui = 'bold', },
}

M.replace = {
  a = { fg = colors.white, bg = colors.red , gui = 'bold', },
}

M.inactive = {
  a = { fg = colors.silver, bg = colors.gray , gui = 'bold', },
  b = { fg = colors.gray, bg = colors.black , },
  c = { fg = colors.silver, bg = colors.black , },
}

return M
