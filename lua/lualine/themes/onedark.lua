local onedark = {}

local colors = {
  red            = {"#E06C75", 168},
  dark_red       = {"#BE5046", 131},
  green          = {"#98C379", 114},
  blue           = {"#61AFEF", 75 },
  purple         = {"#C678DD", 176},
  white          = {"#ABB2BF", 249},
  black          = {"#282C34", 236},
  visual_grey    = {"#3E4452", 238},
}

onedark.normal = {
  a = { colors.black, colors.green, 'bold', },
  b = { colors.white,colors.visual_grey, },
  c = { colors.green, colors.black, },
}

onedark.insert = {
  a = { colors.black, colors.blue, 'bold', },
  b = { colors.white,colors.visual_grey, },
  c = { colors.blue, colors.black, },
}

onedark.visual = {
  a = { colors.black, colors.purple, 'bold', },
  b = { colors.white,colors.visual_grey, },
  c = { colors.purple, colors.black, },
}

onedark.replace = {
  a = { colors.black, colors.red, 'bold', },
  b = { colors.white,colors.visual_grey, },
  c = { colors.red, colors.black, },
}

onedark.inactive = {
  a = { colors.black, colors.white, 'bold', },
  b = { colors.white,colors.visual_grey, },
  c = { colors.white, colors.visual_grey, },
}

return onedark
