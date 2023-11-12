-- Copyright (c) 2023 theinhtut
-- MIT license, see LICENSE for more details.
-- stylua: ignore
local colors = {
  sky           = '#2a86ff',
  grass         = '#c8f560',
  squid         = '#925ff0',
  mud           = '#f6c177',
  sky_hi        = '#b2d4ff',
  grass_hi      = '#e6fab7',
  squid_hi      = '#cfb9f8',
  mud_hi        = '#fcddb6',
  night         = '#141414',
  highlight_mid = '#6f6b7b',
  highlight_low = '#302e35',

}

return {
  visual = {
    a = { fg = colors.night, bg = colors.squid, gui = 'bold' },
    b = { fg = colors.squid_hi, bg = colors.highlight_low },
  },
  replace = {
    a = { fg = colors.night, bg = colors.mud, gui = 'bold' },
    b = { fg = colors.mud_hi, bg = colors.highlight_low },
  },
  inactive = {
    a = { fg = colors.highlight_low, bg = colors.night, gui = 'bold' },
    b = { fg = colors.highlight_low, bg = colors.night },
    c = { fg = colors.highlight_low, bg = colors.night },
  },
  normal = {
    a = { fg = colors.night, bg = colors.sky, gui = 'bold' },
    b = { fg = colors.sky_hi, bg = colors.highlight_low },
    c = { fg = colors.highlight_mid, bg = colors.night },
  },
  insert = {
    a = { fg = colors.night, bg = colors.grass, gui = 'bold' },
    b = { fg = colors.grass_hi, bg = colors.highlight_low },
  },
}
