EXTENSION = {}

local function get_color_codes(name)
	local hl = vim.api.nvim_get_hl(0, { name = name })
	local fg = string.format("#%06x", hl.fg and hl.fg or 0)
	local bg = string.format("#%06x", hl.bg and hl.bg or 0)
	return fg, bg
end

local function merge_colors(foreground, background)
	local new_name = foreground .. background
	local fg, _ = get_color_codes(foreground)
	local _, bg = get_color_codes(background)
	vim.api.nvim_set_hl(0, new_name, { fg = fg, bg = bg })
	return string.format("%%#%s#", new_name)
end
local function inverse_color(name)
	local fg, bg = get_color_codes(name)
	local new_name = name .. "_inversed"
	vim.api.nvim_set_hl(0, new_name, { fg = bg, bg = fg })
	return string.format("%%#%s#", new_name)
end

local function parse_control_element(element)
	local e = element:match("(.*)%%#0#$")
	local color, action_element = e:match("^(.-)#%%(.+)$")
	color = color:gsub("^%%#", "")
	return color, "%" .. action_element
end

function EXTENSION.setup(config)
	local dapui = {}
	dapui.filetypes = {
		"dap-repl",
		"dapui_console",
		"dapui_console",
		"dapui_watches",
		"dapui_stacks",
		"dapui_breakpoints",
		"dapui_scopes",
	}

	local get_mode = require("lualine.highlight").get_mode_suffix

	local lualine_color = "lualine_a"
	local lualine_inacitve = "_inactive"
	local default_color = lualine_color .. lualine_inacitve
	local color_start = "%#"
	local color_end = "#"

	local function get_dap_repl_winbar(separator, active)
		local background_color = string.format(lualine_color .. "%s", active and get_mode() or lualine_inacitve)

		local controls_string = color_start .. default_color .. color_end .. " "
		for control_element in require("dapui.controls").controls():gmatch("%S+") do
			local color, action_element = parse_control_element(control_element)
			local new_color = merge_colors(color, default_color)
			local out = new_color .. action_element
			controls_string = controls_string .. " " .. out
		end
		local separator_color = active and inverse_color(background_color) or color_start .. default_color .. color_end
		return "DAP Repl " .. separator_color .. separator .. controls_string
	end

	local function get_dapui_winbar(separator, active)
		local filetype = vim.bo.filetype
		local disabled_filetypes = { "dap-repl" }
		if vim.tbl_contains(disabled_filetypes, filetype) then
			return get_dap_repl_winbar(separator, active)
		else
			return vim.fn.expand("%:t")
		end
	end

	dapui.winbar = {
		lualine_a = {
			{
				function()
					return get_dapui_winbar(config.active_separator, true)
				end,
			},
		},
	}

	dapui.inactive_winbar = {
		lualine_a = {
			{
				function()
					return get_dapui_winbar(config.inactive_separator, false)
				end,
			},
		},
	}
	return dapui
end

return EXTENSION