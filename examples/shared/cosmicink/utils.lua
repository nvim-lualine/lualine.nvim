local M = {}

-- Import the color module
local ink_colors = require("shared.cosmicink.colors")

-- -- Set random seed based on current time for randomness
math.randomseed(os.time())
-- Icon sets for random selection
M.icon_sets = {
	stars = { '★', '☆', '✧', '✦', '✶', '✷', '✸', '✹' }, -- Set of star-like icons
	runes = { '✠', '⛧', '𖤐', 'ᛟ', 'ᚨ', 'ᚱ', 'ᚷ', 'ᚠ', 'ᛉ', 'ᛊ', 'ᛏ', '☠', '☾', '♰', '✟', '☽', '⚚', '🜏' }, -- Set of rune-like symbols
	hearts = { '❤', '♥', '♡', '❦', '❧' }, -- Set of heart-shaped icons
	waves = { '≈', '∿', '≋', '≀', '⌀', '≣', '⌇' }, -- Set of wave-like symbols
	crosses = { '☨', '✟', '♰', '♱', '⛨', "" }, -- Set of cross-like symbols
}

-- Function to select a random icon from a given set
M.get_random_icon = function(icons)
	return icons[math.random(#icons)] -- Returns a random icon from the set
end

-- Function to shuffle the elements in a table
M.shuffle_table = function(tbl)
	local n = #tbl
	while n > 1 do
		local k = math.random(n)
		tbl[n], tbl[k] = tbl[k], tbl[n] -- Swap elements
		n = n - 1                     -- Decrease the size of the unsorted portion
	end
end

-- Create a list of all icon sets to allow for random selection from any set
M.icon_sets_list = {}
for _, icons in pairs(M.icon_sets) do
	table.insert(M.icon_sets_list, icons) -- Add each icon set to the list
end
M.shuffle_table(M.icon_sets_list)      -- Shuffle the icon sets list


-- Function to reverse the order of elements in a table
M.reverse_table = function(tbl)
	local reversed = {}
	for i = #tbl, 1, -1 do
		table.insert(reversed, tbl[i]) -- Insert elements in reverse order
	end
	return reversed
end

-- Create a reversed list of icon sets
M.reversed_icon_sets = M.reverse_table(M.icon_sets_list)

-- Function to create a separator component based on side (left/right) and optional mode color
M.create_separator = function(side, use_mode_color)
	return {
		function()
			return side == 'left' and '' or '' -- Choose separator symbol based on side
		end,
		color = function()
			-- Set color based on mode or opposite color
			local color = use_mode_color and ink_colors.get_mode_color() or
					ink_colors.get_opposite_color(ink_colors.get_mode_color())
			return {
				fg = color,
			}
		end,
		padding = {
			left = 0,
		},
	}
end

-- Function to create a mode-based component (e.g., statusline)
-- with optional content, icon, and colors
M.create_mode_based_component = function(content, icon, color_fg, color_bg)
	return {
		content,
		icon = icon,
		color = function()
			local mode_color = ink_colors.get_mode_color()
			local opposite_color = ink_colors.get_opposite_color(mode_color)
			return {
				fg = color_fg or ink_colors.color.FG,
				bg = color_bg or opposite_color,
				gui = 'bold',
			}
		end,
	}
end

-- -- Function to get the current mode indicator as a single character
M.mode = function()
	-- Map of modes to their respective shorthand indicators
	local mode_map = {
		n = 'N',    -- Normal mode
		i = 'I',    -- Insert mode
		v = 'V',    -- Visual mode
		[''] = 'V', -- Visual block mode
		V = 'V',    -- Visual line mode
		c = 'C',    -- Command-line mode
		no = 'N',   -- NInsert mode
		s = 'S',    -- Select mode
		S = 'S',    -- Select line mode
		ic = 'I',   -- Insert mode (completion)
		R = 'R',    -- Replace mode
		Rv = 'R',   -- Virtual Replace mode
		cv = 'C',   -- Command-line mode
		ce = 'C',   -- Ex mode
		r = 'R',    -- Prompt mode
		rm = 'M',   -- More mode
		['r?'] = '?', -- Confirm mode
		['!'] = '!', -- Shell mode
		t = 'T',    -- Terminal mode
	}
	-- Return the mode shorthand or [UNKNOWN] if no match
	return mode_map[vim.fn.mode()] or "[UNKNOWN]"
end

return M
