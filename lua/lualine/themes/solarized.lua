-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: itchyny(lightline)
-- License: MIT License
local background = vim.opt.background:get()
local colors = {}

if vim.o.termguicolors then
  colors = {
    base03  = '#002b36',
    base02  = '#073642',
    base01  = '#586e75',
    base00  = '#657b83',
    base0   = '#839496',
    base1   = '#93a1a1',
    base2   = '#eee8d5',
    base3   = '#fdf6e3',
    yellow  = '#b58900',
    orange  = '#cb4b16',
    red     = '#dc322f',
    magenta = '#d33682',
    violet  = '#6c71c4',
    blue    = '#268bd2',
    cyan    = '#2aa198',
    green   = '#859900',
  }
else
  colors = {
    base03  = 8,
    base02  = 0,
    base01  = 10,
    base00  = 11,
    base0   = 12,
    base1   = 14,
    base2   = 7,
    base3   = 15,
    yellow  = 3,
    orange  = 9,
    red     = 1,
    magenta = 5,
    violet  = 13,
    blue    = 4,
    cyan    = 6,
    green   = 2,
  }
end

if background == "light" then
  colors.base3, colors.base03 = colors.base03, colors.base3
  colors.base2, colors.base02 = colors.base02, colors.base2
  colors.base1, colors.base01 = colors.base01, colors.base1
  colors.base0, colors.base00 = colors.base00, colors.base0
end

return {
  normal = {
    a = { fg = colors.base03, bg = colors.blue, gui = 'bold' },
    b = { fg = colors.base03, bg = colors.base1 },
    c = { fg = colors.base1, bg = colors.base02 },
  },
  insert = { a = { fg = colors.base03, bg = colors.green, gui = 'bold' } },
  visual = { a = { fg = colors.base03, bg = colors.magenta, gui = 'bold' } },
  replace = { a = { fg = colors.base03, bg = colors.red, gui = 'bold' } },
  inactive = {
    a = { fg = colors.base0, bg = colors.base02, gui = 'bold' },
    b = { fg = colors.base03, bg = colors.base00 },
    c = { fg = colors.base01, bg = colors.base02 },
  },
}
