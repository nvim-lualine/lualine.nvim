-- Credits:
-- @atahabaki for implementing this theme,
local colors = {
  gray       = '#2a273f', -- palette: Surface
  lightgray  = '#393552', -- palette: Overlay
  orange     = '#ea9a97', -- palette: Rose
  red        = '#eb6f92', -- palette: Love
  yellow     = '#f6c177', -- palette: Gold
  green      = '#9ccfd8', -- palette: Foam
  white      = '#e0def4', -- palette: Text
  black      = '#232136', -- palette: Base
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
