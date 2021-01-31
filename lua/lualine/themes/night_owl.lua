local night_owl = {}

local colors = {
  blue       = {"#82aaff", 111},
  black      = {"#011627", 233},
  white      = {"#d6deeb", 253},
  grey_1     = {"#1d3b53", 222},
  grey_2     = {"#1a2b4a", 235},
  green      = {"#addb67", 149},
  pink       = {"#c792ea", 176},
  red        = {"#ff5874", 204},
  cyan       = {"#7fdbca", 116},
}

night_owl.normal = {
  a = { bg = colors.blue, fg = colors.black, gui = 'bold', },
  b = { bg = colors.grey_1, fg  = colors.white, },
  c = { bg = colors.grey_2, fg = colors.white, }
}

night_owl.insert = {
  a = { bg = colors.green, fg = colors.black, gui = 'bold', },
  b = { bg = colors.grey_1, fg  = colors.white, },
  c = { bg = colors.grey_2, fg = colors.white, }
}

night_owl.visual = {
  a = { bg = colors.pink, fg = colors.black, gui = 'bold', },
  b = { bg = colors.grey_1, fg  = colors.white, },
  c = { bg = colors.grey_2, fg = colors.white, }
}

night_owl.replace = {
  a = { bg = colors.red, fg = colors.black, gui = 'bold', },
  b = { bg = colors.grey_1, fg  = colors.white, },
  c = { bg = colors.grey_2, fg = colors.white, }
}

night_owl.command = {
  a = { bg = colors.cyan, fg = colors.black, gui = 'bold', },
  b = { bg = colors.grey_1, fg  = colors.white, },
  c = { bg = colors.grey_2, fg = colors.white, }
}

night_owl.inactive = {
  a = { bg = colors.black, fg = colors.white, gui = 'bold', },
  b = { bg = colors.black, fg = colors.white, },
  c = { bg = colors.black, fg = colors.white, },
}

return night_owl
