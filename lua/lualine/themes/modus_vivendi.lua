local modus_vivendi = {}

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

modus_vivendi.normal = {
    -- gui parameter is optional and behaves the same way as in vim's highlight command
    a = {bg = colors.blue, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.blue},
    c = {bg = colors.gray, fg = colors.white}
}

modus_vivendi.insert = {
    a = {bg = colors.cyan, fg = colors.black, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.cyan},
    c = {bg = colors.gray, fg = colors.white}
}

modus_vivendi.visual = {
    a = {bg = colors.magenta, fg = colors.black, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.magenta},
    c = {bg = colors.gray, fg = colors.white}
}

modus_vivendi.replace = {
    a = {bg = colors.red, fg = colors.black, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.red},
    c = {bg = colors.gray, fg = colors.white}
}

modus_vivendi.command = {
    a = {bg = colors.green, fg = colors.black, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.green},
    c = {bg = colors.gray, fg = colors.white}
}

-- you can assign one colorscheme to another, if a colorscheme is
-- undefined it falls back to normal
modus_vivendi.terminal = modus_vivendi.normal

modus_vivendi.inactive = {
    a = {bg = colors.darkgray, fg = colors.lightgray, gui = 'bold'},
    b = {bg = colors.darkgray, fg = colors.lightgray},
    c = {bg = colors.darkgray, fg = colors.lightgray}
}

return modus_vivendi
