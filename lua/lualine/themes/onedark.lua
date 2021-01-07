local M = {  }

local colors = {
  red = "#E06C75",
  dark_red = "#BE5046",
  green = "#98C379",
  yellow = "#E5C07B",
  dark_yellow = "#D19A66",
  blue = "#61AFEF",
  purple = "#C678DD",
  cyan = "#56B6C2",
  white = "#ABB2BF",
  black = "#282C34",
  visual_black = "NONE",
  comment_grey = "#5C6370",
  gutter_fg_grey = "#4B5263",
  cursor_grey = "#2C323C",
  visual_grey = "#3E4452",
  menu_grey = "#3E4452",
  special_grey = "#3B4048",
  vertsplit = "#181A1F",
}

M.normal = {
  a = {
    fg = colors.black,
    bg = colors.green,
    gui = 'bold',
  },
  b = {
    fg = colors.white,
    bg = colors.visual_grey,
  },
  c = {
    fg = colors.green,
    bg = colors.black,
  },
}

M.insert = {
  a = {
    fg = colors.black,
    bg = colors.blue,
    gui = 'bold',
  },
  b = {
    fg = colors.white,
    bg = colors.visual_grey,
  },
  c = {
    fg = colors.blue,
    bg = colors.black,
  },
}

M.visual = {
  a = {
    fg = colors.black,
    bg = colors.purple,
    gui = 'bold',
  },
  b = {
    fg = colors.white,
    bg = colors.visual_grey,
  },
  c = {
    fg = colors.purple,
    bg = colors.black,
  },
}

M.replace = {
  a = {
    fg = colors.black,
    bg = colors.red,
    gui = 'bold',
  },
  b = {
    fg = colors.white,
    bg = colors.visual_grey,
  },
  c = {
    fg = colors.red,
    bg = colors.black,
  },
}

M.inactive = {
  a = {
    fg = colors.black,
    bg = colors.white,
    gui = 'bold',
  },
  b = {
    fg = colors.white,
    bg = colors.visual_grey,
  },
  c = {
    fg = colors.white,
    bg = colors.visual_grey,
  },
}

return M
