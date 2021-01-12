local M = {}

local colors = {
  black        = {"#282828", 235},
  white        = {'#ebdbb2', 223},
  red          = {'#fb4934', 203},
  green        = {'#b8bb26', 143},
  blue         = {'#83a598', 108},
  yellow       = {'#fe8019', 209},
  gray         = {'#a89984', 144},
  darkgray     = {'#3c3836', 237},
  lightgray    = {'#504945', 239},
  inactivegray = {'#7c6f64', 242},

  base03  =  '#002b36',
  base02  =  '#073642',
  base01  =  '#586e75',
  base00  =  '#657b83',
  base0   =  '#839496',
  base1   =  '#93a1a1',
  base2   =  '#eee8d5',
  base3   =  '#fdf6e3',
  yellow  =  '#b58900',
  orange  =  '#cb4b16',
  red     =  '#dc322f',
  magenta =  '#d33682',
  violet  =  '#6c71c4',
  blue    =  '#268bd2',
  cyan    =  '#2aa198',
  green   =  '#859900',



}
if vim.o.background == 'light' then
  colors.base03, colors.base3  =  colors.base3, colors.base03
  colors.base02, colors.base2  =  colors.base2, colors.base02
  colors.base01, colors.base1  =  colors.base1, colors.base01
  colors.base00, colors.base0  =  colors.base0, colors.base00
end

M.normal = {
  a = { fg = colors.base03, bg = colors.blue , gui = 'bold', },
  b = { fg = colors.base03, bg = colors.base1 , },
  c = { fg = colors.base1, bg = colors.base02 , }
}

M.insert = {
  a = { fg = colors.base03, bg = colors.green , gui = 'bold', },
}


M.visual = {
  a = { fg = colors.base03, bg = colors.magenta , gui = 'bold', },
}

M.replace = {
  a = { fg = colors.base03, bg = colors.red , gui = 'bold', },
}

M.inactive = {
  a = { fg = colors.base0, bg = colors.base02 , gui = 'bold', },
  b = { fg = colors.base03, bg = colors.base00 , },
  c = { fg = colors.base01, bg = colors.base02 , },
}

return M
