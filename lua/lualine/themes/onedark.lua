local M = {  }

local Colors = {
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
    fg = Colors.black,
    bg = Colors.green,
  },
  b = {
    fg = Colors.white,
    bg = Colors.visual_grey,
  },
  c = {
    fg = Colors.green,
    bg = Colors.black,
  },
}

M.insert = {
  a = {
    fg = Colors.black,
    bg = Colors.blue,
  },
  b = {
    fg = Colors.white,
    bg = Colors.visual_grey,
  },
  c = {
    fg = Colors.blue,
    bg = Colors.black,
  },
}

M.visual = {
  a = {
    fg = Colors.black,
    bg = Colors.purple,
  },
  b = {
    fg = Colors.white,
    bg = Colors.visual_grey,
  },
  c = {
    fg = Colors.purple,
    bg = Colors.black,
  },
}

M.replace = {
  a = {
    fg = Colors.black,
    bg = Colors.red,
  },
  b = {
    fg = Colors.white,
    bg = Colors.visual_grey,
  },
  c = {
    fg = Colors.red,
    bg = Colors.black,
  },
}

M.terminal = M.normal
M.command = M.normal

M.inactive = {
  a = {
    fg = Colors.black,
    bg = Colors.white,
  },
  b = {
    fg = Colors.white,
    bg = Colors.visual_grey,
  },
  c = {
    fg = Colors.white,
    bg = Colors.visual_grey,
  },
}

return M
