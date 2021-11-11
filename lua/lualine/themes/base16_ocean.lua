-- MIT license, see LICENSE for more details.
-- stylelua: ignore
local colors = {
  color00 = "#2b303b",
  color01 = "#343d46",
  color02 = "#4f5b66",
  color03 = "#65737e",
  color04 = "#a7adba",
  color05 = "#c0c5ce",
  color06 = "#dfe1e8",
  color07 = "#eff1f5",
  color08 = "#bf616a",
  color09 = "#d08770",
  color0A = "#ebcb8b",
  color0B = "#a3be8c",
  color0C = "#96b5b4",
  color0D = "#8fa1b3",
  color0E = "#b48ead",
  color0F = "#ab7967",
}

return {
  normal = {
    a = { fg = colors.color01, bg = colors.color0B, gui = 'bold' },
    b = { fg = colors.color06, bg = colors.color02 },
    c = { fg = colors.color09, bg = colors.color01 }
  },
  insert = {
    a = { fg = colors.color01, bg = colors.color0D, gui = 'bold'},
    b = { fg = colors.color06, bg = colors.color02 },
    c = { fg = colors.color09, bg = colors.color01 }
  },
  replace = {
    a = { fg = colors.color01, bg = colors.color08, gui = 'bold' },
    b = { fg = colors.color06, bg = colors.color02 },
    c = { fg = colors.color09, bg = colors.color01 }
  },
  visual = {
    a = { fg = colors.color01, bg = colors.color0E, gui = 'bold' },
    b = { fg = colors.color06, bg = colors.color02 },
    c = { fg = colors.color09, bg = colors.color01 }
  },
  inactive = {
    a = { fg = colors.color05, bg = colors.color01, gui = 'bold' },
    b = { fg = colors.color05, bg = colors.color01 },
    c = { fg = colors.color05, bg = colors.color01 }
  },
}
