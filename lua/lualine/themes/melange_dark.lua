local colors = {
	grays = {
		bg = "#2A2622",
		overbg = "#38332E",
		sel = "#544A45",
		com = "#998066",
		faded = "#C9B39C",
		fg = "#EDE6DE",
	},
	shades = {
		red = "#6B2E2E",
		yellow = "#997733",
		green = "#244224",
		cyan = "#244242",
		blue = "#242E42",
		magenta = "#422438",
	},
	tones = {
		red = "#B34D4D",
		yellow = "#E09952",
		green = "#669966",
		cyan = "#85ADAD",
		blue = "#5973A6",
		magenta = "#AD85AD",
	},
	tints = {
		red = "#F7856E",
		yellow = "#F7C96E",
		green = "#94D194",
		cyan = "#94D1D1",
		blue = "#94A8D1",
		magenta = "#D194BD",
	},
}

return {
	normal = {
		a = { bg = colors.shades.cyan, fg = colors.tints.cyan, gui = "bold" },
		b = { bg = colors.grays.sel, fg = colors.grays.faded },
		c = { bg = colors.grays.overbg, fg = colors.grays.com, gui = "italic" },
	},
	insert = {
		a = { bg = colors.shades.yellow, fg = colors.tints.yellow, gui = "bold" },
	},
	replace = {
		a = { bg = colors.shades.red, fg = colors.tints.red, gui = "bold" },
	},
	visual = {
		a = { bg = colors.shades.magenta, fg = colors.tints.magenta, gui = "bold" },
	},
	command = {
		a = { bg = colors.shades.green, fg = colors.tints.green, gui = "bold" },
	},
	terminal = {
		a = { bg = colors.shades.green, fg = colors.tints.green, gui = "bold" },
	},
	inactive = {
		a = { bg = colors.grays.overbg, fg = colors.grays.sel, gui = "italic" },
		b = { bg = colors.grays.overbg, fg = colors.grays.sel, gui = "italic" },
		c = { bg = colors.grays.overbg, fg = colors.grays.sel, gui = "italic" },
	},
}
