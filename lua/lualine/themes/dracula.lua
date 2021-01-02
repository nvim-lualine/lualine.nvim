local M = {  }

local Colors = {
    grey      = "#44475a",
    lightGrey = "#5f6a8e",
    orange    = "#ffb86c",
    purple    = "#bd93f9",
    red       = "#ff5555",
    yellow    = "#f1fa8c",
    green     = "#50fa7b",

    white = "#f8f8f2",
    black = "#282a36",
}

M.normal = {
  a = {
    bg = Colors.purple,
    fg = Colors.black,
  },
  b = {
    bg = Colors.lightGrey,
    fg  = Colors.white,
  },
  c = {
    bg = Colors.grey,
    fg = Colors.white,
  }
}

M.insert = {
  a = {
    bg = Colors.green,
    fg = Colors.black,
  },
  b = {
    bg = Colors.lightGrey,
    fg = Colors.white,
  },
  c = {
    bg = Colors.grey,
    fg = Colors.white,
  }
}


M.visual = {
  a = {
    bg = Colors.yellow,
    fg = Colors.black,
  },
  b = {
    bg = Colors.lightGrey,
    fg = Colors.white,
  },
  c = {
    bg = Colors.grey,
    fg = Colors.white,
  },
}

M.replace = {
  a = {
    bg = Colors.red,
    fg = Colors.black,
  },
  b = {
    bg = Colors.lightGrey,
    fg = Colors.white,
  },
  c = {
    bg = Colors.grey,
    fg = Colors.white,
  },
}

M.command = {
  a = {
    bg = Colors.grey,
    fg = Colors.white,
  },
  b = {
    bg = Colors.lightGrey,
    fg = Colors.white,
  },
  c = {
    bg = Colors.purple,
    fg = Colors.white
  },
}

M.terminal = M.normal

M.inactive = {
  a = {
    bg = Colors.white,
    fg = Colors.purple,
  },
  b = {
    bg = Colors.grey,
    fg = Colors.purple,
  },
  c = {
    bg = Colors.purple,
    fg = Colors.purple,
  },
}

return M
