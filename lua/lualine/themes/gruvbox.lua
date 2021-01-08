local gruvbox = {}

local colors = {
  black        = {"#282828", 235},
  white        = {'#ebdbb2', 223},
  red          = {'#fb4934', 203},
  green        = {'#b8bb26', 143},
  blue         = {'#83a598', 108},
  yellow       = {'#fe8019', 209},
  gray         = {'#a89984', 144},
  darkgray     = {'#3c3836', 237},
  lightgray    = {'#504945', 239},
  inactivegray = {'#7c6f64', 242},
}

gruvbox.normal = {
  a = { colors.black, colors.gray, 'bold', },
  b = { colors.white, colors.lightgray, },
  c = { colors.gray , colors.darkgray}
}

gruvbox.insert = {
  a = { colors.black, colors.blue, 'bold', },
  b = { colors.white, colors.lightgray, },
  c = { colors.white , colors.lightgray}
}


gruvbox.visual = {
  a = { colors.black, colors.yellow, 'bold', },
  b = { colors.white, colors.lightgray, },
  c = { colors.black , colors.inactivegray},
}

gruvbox.replace = {
  a = { colors.black, colors.red, 'bold', },
  b = { colors.white, colors.lightgray, },
  c = { colors.white , colors.black},
}

gruvbox.command = {
  a = { colors.black, colors.green, 'bold', },
  b = { colors.white, colors.lightgray, },
  c = { colors.black , colors.inactivegray},
}

gruvbox.inactive = {
  a = { colors.gray, colors.darkgray, 'bold', },
  b = { colors.gray, colors.darkgray, },
  c = { colors.gray , colors.darkgray},
}

return gruvbox
