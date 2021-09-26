-- Copyright (c) 2020-2021 allumik
-- MIT license, see LICENSE for more details.
-- Credit: ronniedroid (modus_vivendi theme)
-- LuaFormatter off
local colors = {
  black = '#000000',
  white = '#ffffff',
  red = '#7f1010',
  green = '#104410',
  blue = '#003497',
  magenta = '#752f50',
  cyan = '#005077',
  gray = '#e0e0e0',
  darkgray = '#404148',
  lightgray = '#efefef'
}
-- LuaFormatter on

return {
  normal = {
    a = {bg = colors.blue, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.blue},
    c = {bg = colors.gray, fg = colors.darkgray}
  },
  insert = {
    a = {bg = colors.cyan, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.cyan},
    c = {bg = colors.gray, fg = colors.darkgray}
  },
  visual = {
    a = {bg = colors.magenta, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.magenta},
    c = {bg = colors.gray, fg = colors.darkgray}
  },
  replace = {
    a = {bg = colors.red, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.red},
    c = {bg = colors.gray, fg = colors.darkgray}
  },
  command = {
    a = {bg = colors.green, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.green},
    c = {bg = colors.gray, fg = colors.darkgray}
  },
  inactive = {
    a = {bg = colors.darkgray, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.darkgray, fg = colors.lightgray},
    c = {bg = colors.darkgray, fg = colors.lightgray}
  }
}
