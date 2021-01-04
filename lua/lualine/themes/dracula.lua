local M = {  }

local colors = {
  grey       = "#44475a",
  light_gray = "#5f6a8e",
  orange     = "#ffb86c",
  purple     = "#bd93f9",
  red        = "#ff5555",
  yellow     = "#f1fa8c",
  green      = "#50fa7b",

  white      = "#f8f8f2",
  black      = "#282a36",
}

M.normal = {
  a = {
    bg = colors.purple,
    fg = colors.black,
  },
  b = {
    bg = colors.light_gray,
    fg  = colors.white,
  },
  c = {
    bg = colors.grey,
    fg = colors.white,
  }
}

M.insert = {
  a = {
    bg = colors.green,
    fg = colors.black,
  },
  b = {
    bg = colors.light_gray,
    fg = colors.white,
  },
  c = {
    bg = colors.grey,
    fg = colors.white,
  }
}


M.visual = {
  a = {
    bg = colors.yellow,
    fg = colors.black,
  },
  b = {
    bg = colors.light_gray,
    fg = colors.white,
  },
  c = {
    bg = colors.grey,
    fg = colors.white,
  },
}

M.replace = {
  a = {
    bg = colors.red,
    fg = colors.black,
  },
  b = {
    bg = colors.light_gray,
    fg = colors.white,
  },
  c = {
    bg = colors.grey,
    fg = colors.white,
  },
}

M.command = {
  a = {
    bg = colors.grey,
    fg = colors.white,
  },
  b = {
    bg = colors.light_gray,
    fg = colors.white,
  },
  c = {
    bg = colors.purple,
    fg = colors.white
  },
}

M.terminal = M.normal

M.inactive = {
  a = {
    bg = colors.white,
    fg = colors.purple,
  },
  b = {
    bg = colors.grey,
    fg = colors.purple,
  },
  c = {
    bg = colors.purple,
    fg = colors.purple,
  },
}

return M
