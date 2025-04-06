local colors = {
  bg = '#282a2e',
  alt_bg = '#373b41',
  dark_fg = '#969896',
  fg = '#b4b7b4',
  light_fg = '#c5c8c6',
  normal = '#81a2be',
  insert = '#b5bd68',
  visual = '#b294bb',
  replace = '#de935f',
}

local theme = {
  normal = {
    a = { fg = colors.bg, bg = colors.normal },
    b = { fg = colors.light_fg, bg = colors.alt_bg },
    c = { fg = colors.fg, bg = colors.bg },
  },
  replace = {
    a = { fg = colors.bg, bg = colors.replace },
    b = { fg = colors.light_fg, bg = colors.alt_bg },
  },
  insert = {
    a = { fg = colors.bg, bg = colors.insert },
    b = { fg = colors.light_fg, bg = colors.alt_bg },
  },
  visual = {
    a = { fg = colors.bg, bg = colors.visual },
    b = { fg = colors.light_fg, bg = colors.alt_bg },
  },
  inactive = {
    a = { fg = colors.dark_fg, bg = colors.bg },
    b = { fg = colors.dark_fg, bg = colors.bg },
    c = { fg = colors.dark_fg, bg = colors.bg },
  },
}

theme.command = theme.normal
theme.terminal = theme.insert

return theme
