local M = {}

local colors = {
  base03  = { '#242424', 235 },
  base023 = { '#353535', 236 },
  base02  = { '#444444', 238 },
  base01  = { '#585858', 240 },
  base00  = { '#666666', 242 },
  base0   = { '#808080', 244 },
  base1   = { '#969696', 247 },
  base2   = { '#a8a8a8', 248 },
  base3   = { '#d0d0d0', 252 },
  yellow  = { '#cae682', 180 },
  orange  = { '#e5786d', 173 },
  red     = { '#e5786d', 203 },
  magenta = { '#f2c68a', 216 },
  blue    = { '#8ac6f2', 117 },
  cyan    = { '#8ac6f2', 117 },
  green   = { '#95e454', 119 },




}

M.normal = {
  a = { fg = colors.base02, bg = colors.blue , gui = 'bold', },
  b = { fg = colors.base02, bg = colors.base0 , },
  c = { fg = colors.base2, bg = colors.base02 , }
}

M.insert = {
  a = { fg = colors.base02, bg = colors.green , gui = 'bold', },
}


M.visual = {
  a = { fg = colors.base02, bg = colors.magenta , gui = 'bold', },
}

M.replace = {
  a = { fg = colors.base023, bg = colors.red , gui = 'bold', },
}

M.inactive = {
  a = { fg = colors.base1, bg = colors.base02 , gui = 'bold', },
  b = { fg = colors.base023, bg = colors.base01 , },
  c = { fg = colors.base1, bg = colors.base023 , },
}

return M
