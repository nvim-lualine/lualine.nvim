function _getHi( scope, syntaxlist )
	local color
	for i , syn in ipairs( syntaxlist  ) do
		color = vim.api.nvim_command_output(
			[[ execute 'hi ]] .. syn .. [[']]
		)
		if color:match( [[gui=reverse]] ) then
			if scope == 'guifg' then scope = 'guibg' else scope = 'guifg' end
		end
		color = color:match( scope .. [[=(#?%w+)]]) or nil
		if color then break end
	end
	return color or '#000000'
end

local _ = {
	normal  = _getHi( 'guibg', {'PmenuSel', 'PmenuThumb', 'TabLineSel' } ),
	insert  = _getHi( 'guifg', {'String', 'MoreMsg' } ),
	replace = _getHi( 'guifg', {'Number', 'Type' } ),
	visual  = _getHi( 'guifg', {'Special', 'Boolean', 'Constant' } ),
	command = _getHi( 'guifg', {'Identifier' } ),
	back1   = _getHi( 'guibg', {'Normal', 'StatusLineNC' } ),
	fore    = _getHi( 'guifg', {'Normal', 'StatusLine' } ),
	back2   = _getHi( 'guibg', {'StatusLine' } ),
}

local M = {
	normal = {
		a = { bg = _.normal,  fg = _.back1  },
		b = { bg = _.back1,   fg = _.normal },
		c = { bg = _.back2,   fg = _.fore   },
	},
	insert = {
		a = { bg = _.insert,  fg = _.back1  },
		b = { bg = _.back1,   fg = _.insert },
		c = { bg = _.back2,   fg = _.fore   },
	},
	replace = {
		a = { bg = _.replace, fg= _.back1   },
		b = { bg = _.back1,   fg= _.replace },
		c = { bg = _.back2,   fg= _.fore    },
	},
	visual = {
		a = { bg = _.visual,  fg= _.back1   },
		b = { bg = _.back1,   fg= _.visual  },
		c = { bg = _.back2,   fg= _.fore    },
	},
	command = {
		a = { bg = _.command, fg = _.back1  },
		b = { bg = _.back1,   fg = _.command},
		c = { bg = _.back2,   fg = _.fore   },
	},
}

M.terminal = M.command
M.inactive = M.normal

return M
