-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: TKNGUE(lightline)
-- stylua: ignore
local colors = {
  red                    = '#df0000',
  green                  = '#008700',
  blue                   = '#4271ae',
  pink                   = '#d7005f',
  olive                  = '#718c00',
  navy                   = '#005f87',
  orange                 = '#d75f00',
  purple                 = '#8959a8',
  aqua                   = '#3e999f',
  foreground             = '#4d4d4c',
  background             = '#F5F5F5',
  window                 = '#efefef',
  status                 =  '#3e999f',
  error                  = '#ffafdf',
  statusline_active_fg   =  '#efefef',
  statusline_active_bg   =  '#005f87',
  statusline_inactive_fg =  '#4d4d4c',
  statusline_inactive_bg = '#dadada',
}

return {
  normal = {
    a = { fg = colors.foreground, bg = colors.background, gui = 'bold' },
    b = { fg = colors.statusline_active_fg, bg = colors.status },
    c = { fg = colors.statusline_active_fg, bg = colors.statusline_active_bg },
  },
  insert = { a = { fg = colors.blue, bg = colors.background, gui = 'bold' } },
  visual = { a = { fg = colors.background, bg = colors.orange, gui = 'bold' } },
  replace = { a = { fg = colors.background, bg = colors.pink, gui = 'bold' } },
  inactive = {
    a = { fg = colors.foreground, bg = colors.background, gui = 'bold' },
    b = { fg = colors.foreground, bg = colors.background },
    c = { fg = colors.foreground, bg = colors.background },
  },
}
