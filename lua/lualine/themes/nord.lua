local nord = {}

local colors = {
  nord1  = {"#3B4252", 237},
  nord3  = {"#4C566A", 240},
  nord5  = {"#E5E9F0", 254},
  nord6  = {"#ECEFF4", 255},
  nord7  = {"#8FBCBB", 158},
  nord8  = {"#88C0D0", 159},
  nord13 = {"#EBCB8B", 221},
}

nord.normal = {
  a = { colors.nord1, colors.nord8, 'bold', },
  b = { colors.nord5,colors.nord1, },
  c = { colors.nord5, colors.nord3, }
}

nord.insert = {
  a = { colors.nord1, colors.nord6, 'bold', },
}

nord.visual = {
  a = { colors.nord1, colors.nord7, 'bold', },
}

nord.replace = {
  a = { colors.nord1, colors.nord13, 'bold', },
}

nord.inactive = {
  a = { colors.nord1, colors.nord8, 'bold', },
  b = { colors.nord5,colors.nord1, },
  c = { colors.nord5, colors.nord1, },
}

return nord
