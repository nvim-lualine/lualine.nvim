-- Copyright (c) 2020-2021 ronniedroid
-- MIT license, see LICENSE for more details.
local modus_vivendi = {}
-- LuaFormatter off
local colors = {
    black = '#000000',
    white = '#eeeeee',
    red = '#ffa0a0',
    green = '#88cf88',
    blue = '#92baff',
    magenta = '#feacd0',
    cyan = '#a0bfdf',
    gray = '#2f2f2f',
    darkgray = '#202020',
    lightgray = '#434343'
}
-- LuaFormatter on

modus_vivendi.normal = {
    a = {bg = colors.blue, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.blue},
    c = {bg = colors.gray, fg = colors.white}
}

modus_vivendi.insert = {
    a = {bg = colors.cyan, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.cyan},
    c = {bg = colors.gray, fg = colors.white}
}

modus_vivendi.visual = {
    a = {bg = colors.magenta, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.magenta},
    c = {bg = colors.gray, fg = colors.white}
}

modus_vivendi.replace = {
    a = {bg = colors.red, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.red},
    c = {bg = colors.gray, fg = colors.white}
}

modus_vivendi.command = {
    a = {bg = colors.green, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.green},
    c = {bg = colors.gray, fg = colors.white}
}

modus_vivendi.terminal = modus_vivendi.normal

modus_vivendi.inactive = {
    a = {bg = colors.darkgray, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.darkgray, fg = colors.lightgray},
    c = {bg = colors.darkgray, fg = colors.lightgray}
}

return modus_vivendi
