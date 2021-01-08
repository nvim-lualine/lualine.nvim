local forest_night = {}

local colors = {
  bg0    = {"#323d43", 237},
  bg1    = {"#3c474d", 238},
  bg3    = {"#505a60", 240},
  fg     = {"#d8caac", 187},
  aqua   = {"#87c095", 108},
  green  = {"#a7c080", 144},
  orange = {"#e39b7b", 180},
  purple = {"#d39bb6", 181},
  red    = {"#e68183", 174},
  grey1  = {"#868d80", 102},
}

forest_night.normal = {
  a = { colors.bg0, colors.green, 'bold', },
  b = { colors.fg, colors.bg3, },
  c = { colors.fg, colors.bg1, },
}

forest_night.insert = {
  a = { colors.bg0, colors.fg, 'bold', },
  b = { colors.fg, colors.bg3, },
  c = { colors.fg, colors.bg1, },
}

forest_night.visual = {
  a = { colors.bg0, colors.red, 'bold', },
  b = { colors.fg, colors.bg3, },
  c = { colors.fg, colors.bg1, },
}

forest_night.replace = {
  a = { colors.bg0, colors.orange, 'bold', },
  b = { colors.fg, colors.bg3, },
  c = { colors.fg, colors.bg1, },
}

forest_night.command = {
  a = { colors.bg0, colors.aqua, 'bold', },
  b = { colors.fg, colors.bg3, },
  c = { colors.fg, colors.bg1, },
}

forest_night.terminal = {
  a = { colors.bg0, colors.purple, 'bold', },
  b = { colors.fg, colors.bg3, },
  c = { colors.fg, colors.bg1, },
}

forest_night.inactive = {
  a = { colors.grey1, colors.bg1, 'bold', },
  b = { colors.grey1, colors.bg1, },
  c = { colors.grey1, colors.bg1, },
}

return forest_night
