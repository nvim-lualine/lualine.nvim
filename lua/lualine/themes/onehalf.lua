-- =============================================================================
-- Genarated by lightline to lualine theme converter
--   https://gist.github.com/shadmansaleh/000871c9a608a012721c6acc6d7a19b9
-- License: MIT License
-- =============================================================================

local colors = {
  color0   = "#282c34",
  color1   = "#61afef",
  color2   = "#dcdfe4",
  color3   = "#5d677a",
  color4   = "#313640",
  color5   = "#98c379",
  color6   = "#e5c07b",
  color7   = "#e06c75",
}

local onehalfdark = {
  insert = {
    a = { fg = colors.color0, bg = colors.color1 , "bold", },
    b = { fg = colors.color2, bg = colors.color3 },
    c = { fg = colors.color1, bg = colors.color4 },
  },
  normal = {
    a = { fg = colors.color0, bg = colors.color5 , "bold", },
    b = { fg = colors.color2, bg = colors.color3 },
    c = { fg = colors.color5, bg = colors.color4 },
  },
  inactive = {
    a = { fg = colors.color2, bg = colors.color3 , "bold", },
    b = { fg = colors.color2, bg = colors.color3 },
    c = { fg = colors.color2, bg = colors.color4 },
  },
  visual = {
    a = { fg = colors.color0, bg = colors.color6 , "bold", },
    b = { fg = colors.color2, bg = colors.color3 },
    c = { fg = colors.color6, bg = colors.color4 },
  },
  replace = {
    a = { fg = colors.color0, bg = colors.color7 , "bold", },
    b = { fg = colors.color2, bg = colors.color3 },
    c = { fg = colors.color7, bg = colors.color4 },
  },
}

return onehalfdark