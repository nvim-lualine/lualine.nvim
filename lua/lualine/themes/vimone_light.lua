-- =============================================================================
-- Filename: lua/lualine/themes/vimone_light.lua
-- Author: shadman
-- Credit: Zoltan Dalmadi(lightline)
-- License: MIT License
-- =============================================================================

local M = {}

local colors = {
  blue   = { '#61afef', 75 },
  green  = { '#98c379', 35 },
  purple = { '#c678dd', 176 },
  red1   = { '#e06c75', 168 },
  red2   = { '#be5046', 168 },
  yellow = { '#e5c07b', 180 },
  fg    = { '#494b53', 238 },
  bg    = { '#fafafa', 255 },
  gray1 = { '#494b53', 238 },
  gray2 = { '#f0f0f0', 255 },
  gray3 = { '#d0d0d0', 250 },
}

M.normal = {
  a = { fg = colors.bg, bg = colors.green , gui = 'bold', },
  b = { fg = colors.fg, bg = colors.gray3 , },
  c = { fg = colors.fg, bg = colors.gray2 , }
}

M.insert = {
  a = { fg = colors.bg, bg = colors.blue , gui = 'bold', },
}

M.visual = {
  a = { fg = colors.bg, bg = colors.purple , gui = 'bold', },
}

M.replace = {
  a = { fg = colors.bg, bg = colors.red1 , gui = 'bold', },
}

M.inactive = {
  a = { fg = colors.bg,  bg = colors.gray3 , gui = 'bold', },
  b = { fg = colors.bg, bg = colors.gray3 , },
  c = { fg = colors.gray3, bg = colors.gray2 , },
}

return M
