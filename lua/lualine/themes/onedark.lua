-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: Zoltan Dalmadi(lightline)

local M = {}

local colors = {
  blue   = { '#61afef', 75 },
  green  = { '#98c379', 76 },
  purple = { '#c678dd', 176 },
  red1   = { '#e06c75', 168 },
  red2   = { '#be5046', 168 },
  yellow = { '#e5c07b', 180 },
  fg    = { '#abb2bf', 145 },
  bg    = { '#282c34', 235 },
  gray1 = { '#5c6370', 241 },
  gray2 = { '#2c323d', 235 },
  gray3 = { '#3e4452', 240 },
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
  a = { fg = colors.gray1,  bg = colors.bg , gui = 'bold', },
  b = { fg = colors.gray1, bg = colors.bg , },
  c = { fg = colors.gray1, bg = colors.gray2 , },
}

return M
