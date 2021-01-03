local M = {  }

local P = {
	base0   = "#0c1014",
	base1   = "#111a23",
	base2   = "#091f2e",
	base3   = "#0a3749",
	base4   = "#245361",
	base5   = "#599cab",
	base6   = "#99d1ce",
	base7   = "#d3ebe9",
	red     = "#c23127",
	orange  = "#cb6635",
	yellow  = "#edb443",
	magenta = "#888ca6",
	violet  = "#62477c",
	blue    = "#195466",
	cyan    = "#33859E",
	green   = "#009368",
}

M.normal = {
	a = { bg = P.green,  fg = P.base0  },
	b = { bg = P.base1,  fg = P.base5  },
	c = { bg = P.base0,  fg = P.green  },
}

M.insert = {
	a = { bg = P.orange, fg = P.base0  },
	b = { bg = P.base1,  fg = P.base5  },
	c = { bg = P.base0,  fg = P.orange },
}
M.replace = {
	a = { bg = P.yellow, fg = P.base0  },
	b = { bg = P.base1,  fg = P.base5  },
	c = { bg = P.base0,  fg = P.yellow },
}
M.visual = {
	a = { bg = P.red,    fg = P.base0  },
	b = { bg = P.base1,  fg = P.base5  },
	c = { bg = P.base0,  fg = P.red    },
}
M.command = {
	a = { bg = P.base4,  fg = P.base0  },
	b = { bg = P.base2,  fg = P.base5  },
	c = { bg = P.base0,  fg = P.base5  },
}

M.terminal = M.command
M.inactive = M.command

return M
