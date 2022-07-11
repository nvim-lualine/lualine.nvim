-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
  fg1    = "#3c3836",
  fg4    = "#7c6f64",
  bg0    = "#fbf1c7",
  bg1    = "#ebdbb2",
  bg2    = "#d5c4a1",
  bg4    = "#a89984",
  green  = "#79740e",
  blue   = "#076678",
  aqua   = "#427b58",
  orange = "#af3a03",
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
