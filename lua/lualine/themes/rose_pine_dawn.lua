-- Credits:
-- @atahabaki for implementing this theme,
local colors = {
  gray       = '#fffaf3', -- palette: Surface
  lightgray  = '#f2e9e1', -- palette: Overlay
  orange     = '#d7827e', -- palette: Rose
  red        = '#b4637a', -- palette: Love
  yellow     = '#ea9d34', -- palette: Gold
  green      = '#56949f', -- palette: Foam
  white      = '#575279', -- palette: Text
  black      = '#faf4ed', -- palette: Base
}

return {
  normal = {
    a = { bg = colors.black, fg = colors.white, gui = 'bold' },
    b = { bg = colors.gray, fg = colors.white },
    c = { bg = colors.lightgray, fg = colors.white },
  },
  insert = {
    a = { bg = colors.green, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.gray, fg = colors.white },
  },
  visual = {
    a = { bg = colors.yellow, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.gray, fg = colors.white },
  },
  replace = {
    a = { bg = colors.red, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.gray, fg = colors.white },
  },
  command = {
    a = { bg = colors.orange, fg = colors.black, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.gray, fg = colors.white },
  },
  inactive = {
    a = { bg = colors.gray, fg = colors.white, gui = 'bold' },
    b = { bg = colors.lightgray, fg = colors.white },
    c = { bg = colors.gray, fg = colors.white },
  },
}
