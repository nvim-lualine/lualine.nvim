local colors = {
color1   = "#100E23",
color2   = "#1e1c31",
color3   = "#3E3859",
color4   = "#cbe3e7",
color5   = "#6B697E",
color8   = "#A1EFD3",
color9   = "#62d196",
color6   = "#ffe9aa",
color7   = "#ffb378",
color10  = "#F48FB1",
color11  = "#ff5458",
color12  = "#aaffe4",
color13  = "#c991e1",
color14  = "#a37acc",
}

local embark = {
  normal = {
    c = { fg = colors.color5, bg = colors.color2 },
    a = { fg = colors.color1, bg = colors.color12 , gui = "bold", },
    b = { fg = colors.color4, bg = colors.color3 },
  },
  insert = {
    a = { fg = colors.color1, bg = colors.color10 , gui = "bold", },
    b = { fg = colors.color1, bg = colors.color11 },
  },
  visual = {
    a = { fg = colors.color1, bg = colors.color6 , gui = "bold", },
    b = { fg = colors.color1, bg = colors.color7 },
  },
  replace = {
    a = { fg = colors.color1, bg = colors.color8 , gui = "bold", },
    b = { fg = colors.color1, bg = colors.color9 },
  },
  command = {
    a = { fg = colors.color1, bg = colors.color13 , gui = "bold", },
    b = { fg = colors.color1, bg = colors.color14 },
  },
  inactive = {
    c = { fg = colors.color5, bg = colors.color1 },
    a = { fg = colors.color5, bg = colors.color2 , gui = "bold", },
    b = { fg = colors.color5, bg = colors.color2 },
  },
}

return embark
