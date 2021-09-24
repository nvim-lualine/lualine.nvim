-- Copyright (c) 2021 DanisDGK
-- MIT license, see LICENSE for more details.
-- LuaFormatter off
local colors = {
  black           = "#000000",
  medium_gray     = "#767676",
  subtle_black    = "#121212",
  light_black     = "#262626",
  lightest_gray   = "#EEEEEE",
  dark_pink       = "#ff5f87",
}
--LuaFormatter on
return {
  normal = {
    a = {bg = colors.dark_pink, fg = colors.black, gui = 'bold'},
    b = {bg = colors.black, fg = colors.dark_pink},
    c = {bg = colors.subtle_black, fg = colors.lightest_gray}
  },
  insert = {
    a = {bg = colors.dark_pink, fg = colors.black, gui = 'bold'},
    b = {bg = colors.black, fg = colors.dark_pink},
    c = {bg = colors.subtle_black, fg = colors.lightest_gray}
  },
  visual = {
    a = {bg = colors.medium_gray, fg = colors.black, gui = 'bold'},
    b = {bg = colors.black, fg = colors.medium_gray},
    c = {bg = colors.subtle_black, fg = colors.lightest_gray}
  },
  replace = {
    a = {bg = colors.dark_pink, fg = colors.black, gui = 'bold'},
    b = {bg = colors.black, fg = colors.dark_pink},
    c = {bg = colors.subtle_black, fg = colors.lightest_gray}
  },
  command = {
    a = {bg = colors.lightest_gray, fg = colors.black, gui = 'bold'},
    b = {bg = colors.black, fg = colors.lightest_gray},
    c = {bg = colors.subtle_black, fg = colors.lightest_gray}
  },
  inactive = {
    a = {bg = colors.light_black, fg = colors.lightest_gray, gui = 'bold'},
    b = {bg = colors.light_black, fg = colors.lightest_gray},
    c = {bg = colors.light_black, fg = colors.lightest_gray}
  }
}
