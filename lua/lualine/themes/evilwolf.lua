-- Copyright (c) 2020-2021 gnuyent
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
-- Global
  t0   = '#141413',
  t1   = '#fbd485',
  bg0  = '#242321',
-- Mode-specific
  nbg  = '#aeee00',
  ibg  = '#0a9dff',
  vbg  = '#ffa724',
  rbg  = '#ff9eb8',
  cbg  = '#f4cf86',
  xbg  = '#d7d7b1',
  tbg  = '#d345c7',
  purple = '#ff06a8',
}

return {
  normal = {
    a = { bg = colors.nbg, fg = colors.t0, gui = 'bold' },
    b = { bg = colors.bg0, fg = colors.nbg },
    c = { bg = colors.bg0, fg = colors.t1 },
  },
  insert = {
    a = { bg = colors.ibg, fg = colors.t0, gui = 'bold' },
    b = { bg = colors.bg0, fg = colors.ibg },
    c = { bg = colors.bg0, fg = colors.t1 },
  },
  visual = {
    a = { bg = colors.vbg, fg = colors.t0, gui = 'bold' },
    b = { bg = colors.bg0, fg = colors.vbg },
    c = { bg = colors.bg0, fg = colors.t1 },
  },
  replace = {
    a = { bg = colors.rbg, fg = colors.t0, gui = 'bold' },
    b = { bg = colors.bg0, fg = colors.rbg },
    c = { bg = colors.bg0, fg = colors.t1 },
  },
  command = {
    a = { bg = colors.cbg, fg = colors.t0, gui = 'bold' },
    b = { bg = colors.bg0, fg = colors.cbg },
    c = { bg = colors.bg0, fg = colors.t1 },
  },
  terminal = {
    a = { bg = colors.tbg, fg = colors.t0, gui = 'bold' },
    b = { bg = colors.bg0, fg = colors.purple },
    c = { bg = colors.bg0, fg = colors.t1 },
  },
  inactive = {
    a = { bg = colors.xbg, fg = colors.t0, gui = 'bold' },
    b = { bg = colors.bg0, fg = colors.xbg },
    c = { bg = colors.bg0, fg = colors.t1 },
  },
}
