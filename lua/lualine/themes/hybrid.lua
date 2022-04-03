-- Copyright (c) 2022 jonathf
-- MIT license, see LICENSE for more details.
-- Credit https://github.com/w0ng/vim-hybrid
-- stylua: ignore

local colors = {
  black        = "#1d1f21",
  red          = "#cc6666",
  green        = "#b5bd68",
  yellow       = "#f0c674",
  blue         = "#81a2be",
  magenta      = "#b294bb",
  cyan         = "#8abeb7",
  white        = "#c5c8c6",
  brblack      = "#2d3c46",
  brred        = "#a54242",
  brgreen      = "#8c9440",
  bryellow     = "#de935f",
  brblue       = "#5f819d",
  brmagenta    = "#85678f",
  brcyan       = "#5e8d87",
  brwhite      = "#6c7a80",
}

return {
  normal = {
    a = {bg = colors.green, fg = colors.black},
    b = {bg = colors.black, fg = colors.green},
    c = {bg = colors.black, fg = colors.white}
  },
  insert = {
    a = {bg = colors.yellow, fg = colors.black},
    b = {bg = colors.black, fg = colors.yellow},
    c = {bg = colors.black, fg = colors.white}
  },
  visual = {
    a = {bg = colors.blue, fg = colors.black},
    b = {bg = colors.black, fg = colors.blue},
    c = {bg = colors.black, fg = colors.white}
  },
  replace = {
    a = {bg = colors.red, fg = colors.black},
    b = {bg = colors.black, fg = colors.red},
    c = {bg = colors.black, fg = colors.white}
  },
  command = {
    a = {bg = colors.magenta, fg = colors.black},
    b = {bg = colors.black, fg = colors.magenta},
    c = {bg = colors.black, fg = colors.white}
  },
  terminal = {
    a = {bg = colors.cyan, fg = colors.black},
    b = {bg = colors.black, fg = colors.cyan},
    c = {bg = colors.black, fg = colors.white}
  },
  inactive = {
    a = {bg = colors.black, fg = colors.brwhite},
    b = {bg = colors.black, fg = colors.brwhite},
    c = {bg = colors.black, fg = colors.white}
  },
}
