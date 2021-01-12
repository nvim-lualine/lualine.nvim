local molokai = {}

local colors = {
  black  = { '#232526', 233 },
  gray   = { '#808080', 244 },
  white  = { '#f8f8f2', 234 },
  cyan   = { '#66d9ef', 81  },
  green  = { '#a6e22e', 118 },
  orange = { '#ef5939', 166 },
  pink   = { '#f92672', 161 },
  red    = { '#ff0000', 160 },
  yellow = { '#e6db74', 229 },


}

molokai.normal = {
  a = { fg = colors.black, bg = colors.cyan , gui = 'bold', },
  b = { fg = colors.black, bg = colors.pink , },
  c = { fg = colors.orange, bg = colors.black , }
}

molokai.insert = {
  a = { fg = colors.black, bg = colors.green , gui = 'bold', },
}


molokai.visual = {
  a = { fg = colors.black, bg = colors.yellow , gui = 'bold', },
}

molokai.replace = {
  a = { fg = colors.black, bg = colors.red , gui = 'bold', },
}

molokai.inactive = {
  a = { fg = colors.pink, bg = colors.black , gui = 'bold', },
  b = { fg = colors.white, bg = colors.pink , },
  c = { fg = colors.gray, bg = colors.black , },
}

return molokai
