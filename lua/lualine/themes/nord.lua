local M = {  }

local colors = {
  nord1  = {"#3B4252", 237},
  nord3  = {"#4C566A", 240},
  nord5  = {"#E5E9F0", 254},
  nord6  = {"#ECEFF4", 255},
  nord7  = {"#8FBCBB", 158},
  nord8  = {"#88C0D0", 159},
  nord13 = {"#EBCB8B", 221},

}

M.normal = {
  a = {
    fg = colors.nord1,
    bg = colors.nord8,
    gui = 'bold',
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
    gui = 'bold',
  },
  b = M.normal.b,
  c = M.normal.c,
}


M.visual = {
  a = {
    fg = colors.nord1,
    bg = colors.nord7,
    gui = 'bold',
  },
  b = M.normal.b,
  c = M.normal.c,
}

M.replace = {
  a = {
    fg = colors.nord1,
    bg = colors.nord13,
    gui = 'bold',
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
    gui = 'bold',
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
