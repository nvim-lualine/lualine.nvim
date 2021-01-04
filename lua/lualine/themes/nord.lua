local M = {  }

local colors = {
  nord1  = "#3B4252", 
  nord3  = "#4C566A", 
  nord5  = "#E5E9F0", 
  nord6  = "#ECEFF4", 
  nord7  = "#8FBCBB", 
  nord8  = "#88C0D0", 
  nord13 = "#EBCB8B",

}

M.normal = {
  a = {
    fg = colors.nord1,
    bg = colors.nord8,
  },
  b = {
    fg = colors.nord5,
    bg = colors.nord1,
  },
  c = {
    fg = colors.nord5,
    bg = colors.nord3,
  }
}

M.insert = {
  a = {
    fg = colors.nord1,
    bg = colors.nord6,
  },
  b = M.normal.b,
  c = M.normal.c,
}


M.visual = {
  a = {
    fg = colors.nord1,
    bg = colors.nord7,
  },
  b = M.normal.b,
  c = M.normal.c,
}

M.replace = {
  a = {
    fg = colors.nord1,
    bg = colors.nord13,
  },
  b = M.normal.b,
  c = M.normal.c,
}

M.command = M.normal 

M.terminal = M.normal

M.inactive = {
  a = {
    fg = colors.nord1,
    bg = colors.nord8,
  },
  b = {
    fg = colors.nord5,
    bg = colors.nord1,
  },
  c = {
    fg = colors.nord5,
    bg = colors.nord1,
  },
}

return M
