-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
-- LuaFormatter off
local colors = {
	black = "#282828",
	white = "#ebdbb2",
	red = "#e27d60",
	green = "#2bbb4f",
	blue = "#4799eb",
	dark = "#11121D",
	yellow = "#e6e600",
	gray = "#4d1919",
	darkgray = "#281b10",
	lightgray = "#363636",
	inactivegray = "#986fec",
}
-- LuaFormatter on
return {
	normal = {
		a = { bg = colors.inactivegray, fg = colors.dark, gui = "bold" },
		b = { bg = colors.lightgray, fg = colors.white },
		c = { bg = colors.darkgray, fg = colors.white },
	},
	insert = {
		a = { bg = colors.blue, fg = colors.dark, gui = "bold" },
		b = { bg = colors.gray, fg = colors.white },
		c = { bg = colors.lightgray, fg = colors.white },
	},
	visual = {
		a = { bg = colors.yellow, fg = colors.dark, gui = "bold" },
		b = { bg = colors.lightgray, fg = colors.white },
		c = { bg = colors.gray, fg = colors.white },
	},
	replace = {
		a = { bg = colors.red, fg = colors.dark, gui = "bold" },
		b = { bg = colors.lightgray, fg = colors.white },
		c = { bg = colors.black, fg = colors.white },
	},
	command = {
		a = { bg = colors.green, fg = colors.dark, gui = "bold" },
		b = { bg = colors.darkgray, fg = colors.white },
		c = { bg = colors.lightgray, fg = colors.white },
	},
	inactive = {
		a = { bg = colors.darkgray, fg = colors.white, gui = "bold" },
		b = { bg = colors.darkgray, fg = colors.white },
		c = { bg = colors.darkgray, fg = colors.white },
	},
}