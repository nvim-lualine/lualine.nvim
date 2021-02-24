-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit itchyny, jackno (lightline)

local dracula = {}

local colors = {
  grey       = "#44475a",
  light_gray = "#5f6a8e",
  orange     = "#ffb86c",
  purple     = "#bd93f9",
  red        = "#ff5555",
  yellow     = "#f1fa8c",
  green      = "#50fa7b",
  white      = "#f8f8f2",
  black      = "#282a36",
}

dracula.normal = {
  a = { bg = colors.purple, fg = colors.black, gui = 'bold', },
  b = { bg = colors.light_gray, fg  = colors.white, },
  c = { bg = colors.grey, fg = colors.white, }
}

dracula.insert = {
  a = { bg = colors.green, fg = colors.black, gui = 'bold', },
  b = { bg = colors.light_gray, fg = colors.white, },
  c = { bg = colors.grey, fg = colors.white, }
}

dracula.visual = {
  a = { bg = colors.yellow, fg = colors.black, gui = 'bold', },
  b = { bg = colors.light_gray, fg = colors.white, },
  c = { bg = colors.grey, fg = colors.white, },
}

dracula.replace = {
  a = { bg = colors.red, fg = colors.black, gui = 'bold', },
  b = { bg = colors.light_gray, fg = colors.white, },
  c = { bg = colors.grey, fg = colors.white, },
}

dracula.command = {
  a = { bg = colors.grey, fg = colors.white, gui = 'bold', },
  b = { bg = colors.light_gray, fg = colors.white, },
  c = { bg = colors.purple, fg = colors.white },
}

dracula.inactive = {
  a = { bg = colors.white, fg = colors.purple, gui = 'bold', },
  b = { bg = colors.grey, fg = colors.purple, },
  c = { bg = colors.purple, fg = colors.purple, },
}

return dracula
