-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
  fg1    = "#ebdbb2",
  fg4    = "#a89984",
  bg0    = "#282828",
  bg1    = "#3c3836",
  bg2    = "#504945",
  bg4    = "#7c6f64",
  green  = "#b8bb26",
  blue   = "#83a598",
  aqua   = "#8ec07c",
  orange = "#fe8019",
}

return {
  normal = {
    a = { fg = colors.bg0, bg = colors.fg4 , gui = "bold", },
    b = { fg = colors.fg4, bg = colors.bg2 },
    c = { fg = colors.fg4, bg = colors.bg1 },
  },
  insert = {
    a = { fg = colors.bg0, bg = colors.blue , gui = "bold", },
    b = { fg = colors.fg1, bg = colors.bg2 },
    c = { fg = colors.fg4, bg = colors.bg1 },
  },
  visual = {
    a = { fg = colors.bg0, bg = colors.orange , gui = "bold", },
    b = { fg = colors.bg0, bg = colors.bg4 },
    c = { fg = colors.fg4, bg = colors.bg1 },
  },
  replace = {
    a = { fg = colors.bg0, bg = colors.aqua , gui = "bold", },
    b = { fg = colors.fg1, bg = colors.bg2 },
    c = { fg = colors.fg4, bg = colors.bg1 },
  },
  terminal = {
    a = { fg = colors.bg0, bg = colors.green , gui = "bold", },
    b = { fg = colors.fg1, bg = colors.bg2 },
    c = { fg = colors.fg4, bg = colors.bg1 },
  },
  inactive = {
    a = { fg = colors.bg4, bg = colors.bg1 , gui = "bold", },
    b = { fg = colors.bg4, bg = colors.bg1 },
    c = { fg = colors.bg4, bg = colors.bg1 },
  },
}
