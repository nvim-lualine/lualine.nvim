local colors = {
  color2   = '#161821',
  color3   = '#bc66ff',
  color4   = '#7d1885',
  color5   = '#f571a1',
  color8   = '#ff0000',
  color9   = '#6114de',
  color10  = '#0f1117',
  color11  = '#17171b',
  color12  = '#de1443',
  color15  = '#d414de'
}
-- LuaFormatter on
return {
  visual = {
    a = {fg = colors.color2, bg = colors.color3, gui = 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  },
  replace = {
    a = {fg = colors.color2, bg = colors.color8, gui = 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  },
  inactive = {
    c = {fg = colors.color9, bg = colors.color10},
    a = {fg = colors.color9, bg = colors.color10, gui = 'bold'},
    b = {fg = colors.color9, bg = colors.color10}
  },
  normal = {
    c = {fg = colors.color9, bg = colors.color10},
    a = {fg = colors.color11, bg = colors.color12, gui = 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  },
  insert = {
    a = {fg = colors.color2, bg = colors.color15, gui = 'bold'},
    b = {fg = colors.color4, bg = colors.color5}
  }
}
