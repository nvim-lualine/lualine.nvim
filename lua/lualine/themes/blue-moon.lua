-- Copyright (c) 2023 gzbd
-- MIT license, see LICENSE for more details.
-- Credit: kyazdani42(lightline)
local colors = {
  color0   = "#1b1e2b",
  color1   = "#d0e7d0",
  color2   = "#292d3e",
  color3   = "#697098",
  color4   = "#959dcb",
  color5   = "#89bbdd",
  color6   = "#a9a3db",
}

return {
  replace = {
    a = { fg = colors.color0, bg = colors.color1 , gui = "bold", },
    b = { fg = colors.color1, bg = colors.color2 },
    c = { fg = colors.color3, bg = colors.color0 },
  },
  insert = {
    a = { fg = colors.color0, bg = colors.color4 , gui = "bold", },
    b = { fg = colors.color4, bg = colors.color2 },
    c = { fg = colors.color3, bg = colors.color0 },
  },
  visual = {
    a = { fg = colors.color0, bg = colors.color5 , gui = "bold", },
    b = { fg = colors.color5, bg = colors.color2 },
    c = { fg = colors.color3, bg = colors.color0 },
  },
  normal = {
    a = { fg = colors.color0, bg = colors.color6 , gui = "bold", },
    b = { fg = colors.color6, bg = colors.color2 },
    c = { fg = colors.color3, bg = colors.color0 },
  },
  inactive = {
    a = { fg = colors.color3, bg = colors.color0 , gui = "bold", },
    b = { fg = colors.color3, bg = colors.color0 },
    c = { fg = colors.color3, bg = colors.color0 },
  },
}
