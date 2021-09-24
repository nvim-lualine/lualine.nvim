-- Copyright (c) 2020-2021 G.A. Jazali
-- MIT license, see LICENSE for more details.
-- Original theme from https://github.com/kyoz/purify
-- LuaFormatter off
local colors = {
    blue           = '#5EAFFF',
    green          = '#5FFF87',
    white          = '#FFFFFF',
    darkGrey       = '#282B33',   
    midGrey        = '#282B33',
    lightGrey      = '#3E4452',
    amber          = '#FF875E',
    magenta        = '#FF7AC8',
    darkGreen      = '#324737',
    darkAmber      = '#4D3C36',
    darkMagenta    = '#4D3543',
}
-- LuaFormatter on
return {
    normal = {
        a = {fg = colors.darkGrey, bg = colors.blue, gui = NONE},
        b = {fg = colors.white, bg = colors.lightGrey},
        c = {fg = colors.white, bg = colors.midGrey},
        z = {fg = colors.darkGrey, bg = colors.white}
    },
    insert = {
        a = {fg = colors.darkGrey, bg = colors.green, gui = NONE},
        b = {fg = colors.green, bg = colors.darkGreen},
        c = {fg = colors.green, bg = colors.midGrey},
        z = {fg = colors.darkGrey, bg = colors.white}
    },
    visual = {
        a = {fg = colors.darkGrey, bg = colors.magenta, gui = NONE},
        b = {fg = colors.magenta, bg = colors.darkMagenta},
        c = {fg = colors.magenta, bg = colors.midGrey},
        z = {fg = colors.darkGrey, bg = colors.white}
    },
    replace = {
        a = {fg = colors.darkGrey, bg = colors.amber, gui = NONE},
        b = {fg = colors.amber, bg = colors.darkAmber},
        c = {fg = colors.amber, bg = colors.midGrey},
        z = {fg = colors.darkGrey, bg = colors.white}
    },
    inactive = {
        a = {fg = colors.white, bg = colors.lightGrey, gui = NONE},
        b = {fg = colors.white, bg = colors.lightGrey},
        c = {fg = colors.white, bg = colors.lightGrey}
    }
}
