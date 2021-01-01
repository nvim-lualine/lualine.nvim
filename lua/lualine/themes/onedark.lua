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
    bg = Colors.black,
    fg = Colors.green,
  },
  b = {
    bg = Colors.white,
    fg = Colors.visual_grey,
  },
  c = {
    bg = Colors.green,
    fg = Colors.black,
  },
}

M.insert = {
  a = {
    bg = Colors.black,
    fg = Colors.blue,
  },
  b = {
    bg = Colors.white,
    fg = Colors.visual_grey,
  },
  c = {
    bg = Colors.blue,
    fg = Colors.black,
  },
}

M.visual = {
  a = {
    bg = Colors.black,
    fg = Colors.purple,
  },
  b = {
    bg = Colors.white,
    fg = Colors.visual_grey,
  },
  c = {
    bg = Colors.purple,
    fg = Colors.black,
  },
}

M.replace = {
  a = {
    bg = Colors.black,
    fg = Colors.red,
  },
  b = {
    bg = Colors.white,
    fg = Colors.visual_grey,
  },
  c = {
    bg = Colors.red,
    fg = Colors.black,
  },
}

M.terminal = M.normal

M.inactive = {
  a = {
    bg = Colors.black,
    fg = Colors.white,
  },
  b = {
    bg = Colors.white,
    fg = Colors.visual_grey,
  },
  c = {
    bg = Colors.white,
    fg = Colors.visual_grey,
  },
}

return M
