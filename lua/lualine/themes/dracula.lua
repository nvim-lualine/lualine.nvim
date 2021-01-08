local dracula = {}

local colors = {
  grey       = {"#44475a", 238},
  light_gray = {"#5f6a8e", 60 },
  orange     = {"#ffb86c", 215},
  purple     = {"#bd93f9", 141},
  red        = {"#ff5555", 203},
  yellow     = {"#f1fa8c", 228},
  green      = {"#50fa7b", 84 },
  white      = {"#f8f8f2", 255},
  black      = {"#282a36", 236},
}

dracula.normal = {
  a = { colors.black, colors.purple, 'bold', },
  b = { colors.white, colors.light_gray, },
  c = { colors.white, colors.grey, }
}

dracula.insert = {
  a = { colors.black, colors.green, 'bold', },
  b = { colors.white, colors.light_gray, },
  c = { colors.white, colors.grey, }
}

dracula.visual = {
  a = { colors.black, colors.yellow, 'bold', },
  b = { colors.white, colors.light_gray, },
  c = { colors.white, colors.grey, },
}

dracula.replace = {
  a = { colors.black, colors.red, 'bold', },
  b = { colors.white, colors.light_gray, },
  c = { colors.white, colors.grey, },
}

dracula.command = {
  a = { colors.white, colors.grey, 'bold', },
  b = { colors.white, colors.light_gray, },
  c = { colors.white , colors.purple},
}

dracula.inactive = {
  a = { colors.purple, colors.white, 'bold', },
  b = { colors.purple, colors.grey, },
  c = { colors.purple, colors.purple, },
}

return dracula
