-- =============================================================================
-- Filename: lua/lualine/themes/nightfly.lua
-- Author: shadman
-- License: MIT License
-- =============================================================================

local colors = {
  back1   = "#011627",
  back2   = "#2c4043",
  back3   = "#121212",
  command = "#7fdbca",
  fore    = "#c3ccdc",
  insert  = "#ecc48d",
  normal  = "#3975b6",
  replace = "#21c7a8",
  visual  = "#ff5874",
}

local nightfly = {
  normal = {
    a = { bg = colors.normal,  fg = colors.back1 , gui='bold' },
    b = { bg = colors.back1,   fg = colors.normal },
    c = { bg = colors.back2,   fg = colors.fore   },
  },
  insert = {
    a = { bg = colors.insert,  fg = colors.back1, gui='bold' },
    b = { bg = colors.back1,   fg = colors.insert },
  },
  replace = {
    a = { bg = colors.replace, fg= colors.back1, gui='bold' },
    b = { bg = colors.back1,   fg= colors.replace },
  },
  visual = {
    a = { bg = colors.visual,  fg= colors.back1, gui='bold' },
    b = { bg = colors.back1,   fg= colors.visual  },
  },
  command = {
    a = { bg = colors.command, fg = colors.back1, gui='bold' },
    b = { bg = colors.back1,   fg = colors.command },
  },
  inactive = {
    a = { bg = colors.back3, fg = colors.fore, gui = 'bold' },
    b = { bg = colors.back3, fg = colors.fore },
    c = { bg = colors.back2, fg = colors.fore },
  },
}
return nightfly
