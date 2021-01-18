local colors = {
  color14  = "#718c00",
  color0   = "#666666",
  color1   = "#c8c8c8",
  color2   = "#808080",
  color3   = "#fafafa",
  color4   = "#4271ae",
  color5   = "#4d4d4c",
  color6   = "#b4b4b4",
  color7   = "#555555",
  color8   = "#8959a8",
  color11  = "#f5871f",
}

local Tomorrow = {
  inactive = {
    a = { fg = colors.color0, bg = colors.color1 },
    b = { fg = colors.color2, bg = colors.color3 },
    c = { fg = colors.color0, bg = colors.color1 },
  },
  normal = {
    a = { fg = colors.color1, bg = colors.color4 },
    b = { fg = colors.color5, bg = colors.color6 },
    c = { fg = colors.color7, bg = colors.color1 },
  },
  visual = {
    a = { fg = colors.color1, bg = colors.color8 },
    b = { fg = colors.color5, bg = colors.color6 },
  },
  replace = {
    a = { fg = colors.color1, bg = colors.color11 },
    b = { fg = colors.color5, bg = colors.color6 },
  },
  insert = {
    a = { fg = colors.color1, bg = colors.color14 },
    b = { fg = colors.color5, bg = colors.color6 },
  },
}

return Tomorrow