-- moonfly color scheme for lualine
--
-- URL:     github.com/bluz71/vim-moonfly-colors
-- License: MIT (https://opensource.org/licenses/MIT)

-- stylua: ignore
local colors = {
  color3   = '#303030',
  color6   = '#9e9e9e',
  color7   = '#80a0ff',
  color8   = '#ae81ff',
  color0   = '#1c1c1c',
  color1   = '#ff5189',
  color2   = '#c6c6c6',
}

return {
  replace = {
    a = { fg = colors.color0, bg = colors.color1, gui = 'bold' },
    b = { fg = colors.color2, bg = colors.color3 },
  },
  inactive = {
    a = { fg = colors.color6, bg = colors.color3, gui = 'bold' },
    b = { fg = colors.color6, bg = colors.color3 },
    c = { fg = colors.color6, bg = colors.color3 },
  },
  normal = {
    a = { fg = colors.color0, bg = colors.color7, gui = 'bold' },
    b = { fg = colors.color2, bg = colors.color3 },
    c = { fg = colors.color2, bg = colors.color3 },
  },
  visual = {
    a = { fg = colors.color0, bg = colors.color8, gui = 'bold' },
    b = { fg = colors.color2, bg = colors.color3 },
  },
  insert = {
    a = { fg = colors.color0, bg = colors.color2, gui = 'bold' },
    b = { fg = colors.color2, bg = colors.color3 },
  },
}
