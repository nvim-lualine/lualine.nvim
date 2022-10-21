-- Copyright (c) 2021 Jnhtr
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
    black        = '#111111',
    white        = '#d3d3d3',
    cyan         = '#00afff',
    green        = '#9ECE6A',
    purple       = '#BB9AF7',
    red          = '#F43E5C',
    green2       = '#5fffaf',
    black2       = '#121212',
    lightgray    = '#383838',
    inactivegray = '#1C1E26',
}

return {
    normal = {
        a = { bg = colors.cyan, fg = colors.black, gui = 'bold' },
        b = { bg = colors.lightgray, fg = colors.cyan },
        c = { bg = colors.black2, fg = colors.white },
    },
    insert = {
        a = { bg = colors.green, fg = colors.black, gui = 'bold' },
        b = { bg = colors.lightgray, fg = colors.green },
        c = { bg = colors.black2, fg = colors.white },
    },
    visual = {
        a = { bg = colors.purple, fg = colors.black, gui = 'bold' },
        b = { bg = colors.lightgray, fg = colors.purple },
        c = { bg = colors.black2, fg = colors.white },
    },
    replace = {
        a = { bg = colors.red, fg = colors.black, gui = 'bold' },
        b = { bg = colors.lightgray, fg = colors.red },
        c = { bg = colors.black2, fg = colors.white },
    },
    command = {
        a = { bg = colors.green2, fg = colors.black, gui = 'bold' },
        b = { bg = colors.lightgray, fg = colors.green2 },
        c = { bg = colors.black2, fg = colors.white },
    },
    inactive = {
        a = { bg = colors.inactivegray, fg = colors.lightgray },
        b = { bg = colors.inactivegray, fg = colors.lightgray },
        c = { bg = colors.inactivegray, fg = colors.lightgray },
    },
}
