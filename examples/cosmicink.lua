-- CosmicInk config for lualine
-- Author: Yeeloman
-- MIT license, see LICENSE for more details.

-- Main configuration for setting up lualine.nvim statusline plugin

-- Default Theme Colors: Define a set of base colors for your theme
local colors = {
  BG = '#16181b', -- Dark background
  FG = '#c5c4c4', -- Light foreground for contrast
  YELLOW = '#e8b75f', -- Vibrant yellow
  CYAN = '#00bcd4', -- Soft cyan
  DARKBLUE = '#2b3e50', -- Deep blue
  GREEN = '#00e676', -- Bright green
  ORANGE = '#ff7733', -- Warm orange
  VIOLET = '#7a3ba8', -- Strong violet
  MAGENTA = '#d360aa', -- Deep magenta
  BLUE = '#4f9cff', -- Light-medium blue
  RED = '#ff3344', -- Strong red
}

-- Function to get the color associated with the current mode in Vim
local function get_mode_color()
  -- Define a table mapping modes to their associated colors
  local mode_color = {
    n = colors.DARKBLUE,
    i = colors.VIOLET,
    v = colors.RED,
    [''] = colors.BLUE,
    V = colors.RED,
    c = colors.MAGENTA,
    no = colors.RED,
    s = colors.ORANGE,
    S = colors.ORANGE,
    [''] = colors.ORANGE,
    ic = colors.YELLOW,
    R = colors.ORANGE,
    Rv = colors.ORANGE,
    cv = colors.RED,
    ce = colors.RED,
    r = colors.CYAN,
    rm = colors.CYAN,
    ['r?'] = colors.CYAN,
    ['!'] = colors.RED,
    t = colors.RED,
  }
  -- Return the opposite color, or fallback to foreground color
  return mode_color[vim.fn.mode()]
end

-- Function to get the opposite color of a given mode color
local function get_opposite_color(mode_color)
  -- Define a table mapping colors to their opposite color
  local opposite_colors = {
    [colors.RED] = colors.CYAN,
    [colors.BLUE] = colors.ORANGE,
    [colors.GREEN] = colors.MAGENTA,
    [colors.MAGENTA] = colors.DARKBLUE,
    [colors.ORANGE] = colors.BLUE,
    [colors.CYAN] = colors.YELLOW,
    [colors.VIOLET] = colors.GREEN,
    [colors.YELLOW] = colors.RED,
    [colors.DARKBLUE] = colors.VIOLET,
  }
  -- Return the opposite color, or fallback to foreground color
  return opposite_colors[mode_color] or colors.FG
end

-- Function to get an animated color (randomly chosen from available colors)
local function get_animated_color(mode_color)
  -- Define a list of all available colors
  local all_colors = {
    colors.RED,
    colors.BLUE,
    colors.GREEN,
    colors.MAGENTA,
    colors.ORANGE,
    colors.CYAN,
    colors.VIOLET,
    colors.YELLOW,
    colors.DARKBLUE,
  }
  -- Create a list of possible opposite colors (excluding the current mode color)
  local possible_opposites = {}
  for _, color in ipairs(all_colors) do
    if color ~= mode_color then
      table.insert(possible_opposites, color)
    end
  end
  -- Randomly select an opposite color
  if #possible_opposites > 0 then
    local random_index = math.random(1, #possible_opposites)
    return possible_opposites[random_index]
  else
    return colors.FG -- Default to foreground color if no opposite found
  end
end

-- Function to interpolate between two colors for a smooth transition
local function interpolate_color(color1, color2, step)
  -- Blend two colors based on the given step factor (0.0 -> color1, 1.0 -> color2)
  local blend = function(c1, c2, stp)
    return math.floor(c1 + (c2 - c1) * stp)
  end
  -- Extract the RGB values of both colors (in hex)
  local r1, g1, b1 = tonumber(color1:sub(2, 3), 16), tonumber(color1:sub(4, 5), 16), tonumber(color1:sub(6, 7), 16)
  local r2, g2, b2 = tonumber(color2:sub(2, 3), 16), tonumber(color2:sub(4, 5), 16), tonumber(color2:sub(6, 7), 16)

  -- Calculate the new RGB values for the blended color
  local r = blend(r1, r2, step)
  local g = blend(g1, g2, step)
  local b = blend(b1, b2, step)

  -- Return the blended color in hex format
  return string.format('#%02X%02X%02X', r, g, b)
end

-- Function to get a middle color by interpolating between mode color and its opposite
local function get_middle_color(color_step)
  -- Set default value for color_step if not provided
  color_step = color_step or 0.5 -- If color_step is nil, default to 0.5

  local color1 = get_mode_color() -- Get the current mode color
  local color2 = get_opposite_color(color1) -- Get the opposite color

  -- Return an interpolated color between the two (based on the color_step value)
  return interpolate_color(color1, color2, color_step)
end

-- Condition: Check if the buffer is not empty
-- This checks whether the current file's name is non-empty.
-- If the file is open (i.e., has a name), it returns true, meaning the buffer is not empty.
-- local function buffer_not_empty()
-- 	return vim.fn.empty(vim.fn.expand('%:t')) ~= 1 -- 'expand('%:t')' gets the file name
-- end

-- Condition: Hide in width (only show the statusline when the window width is greater than 80)
-- This ensures that the statusline will only appear if the current window width exceeds 80 characters.
local function hide_in_width()
  return vim.fn.winwidth(0) > 80 -- 'winwidth(0)' returns the current window width
end

-- Condition: Check if the current workspace is inside a Git repository
-- This function checks if the current file is inside a Git repository by looking for a `.git` directory
-- in the current file's path. Returns true if the file is in a Git workspace.
-- local function check_git_workspace()
-- 	local filepath = vim.fn.expand('%:p:h')               -- Get the current file's directory
-- 	local gitdir = vim.fn.finddir('.git', filepath .. ';') -- Search for a `.git` directory in the file path
-- 	return gitdir and #gitdir > 0 and #gitdir < #filepath -- Returns true if a `.git` directory is found
-- end

-- -- Set random seed based on current time for randomness
math.randomseed(os.time())
-- Icon sets for random selection
local icon_sets = {
  stars = { '★', '☆', '✧', '✦', '✶', '✷', '✸', '✹' }, -- Set of star-like icons
  runes = {
    '✠',
    '⛧',
    '𖤐',
    'ᛟ',
    'ᚨ',
    'ᚱ',
    'ᚷ',
    'ᚠ',
    'ᛉ',
    'ᛊ',
    'ᛏ',
    '☠',
    '☾',
    '♰',
    '✟',
    '☽',
    '⚚',
    '🜏',
  }, -- Set of rune-like symbols
  hearts = { '❤', '♥', '♡', '❦', '❧' }, -- Set of heart-shaped icons
  waves = { '≈', '∿', '≋', '≀', '⌀', '≣', '⌇' }, -- Set of wave-like symbols
  crosses = { '☨', '✟', '♰', '♱', '⛨', '' }, -- Set of cross-like symbols
}

-- Function to select a random icon from a given set
local function get_random_icon(icons)
  return icons[math.random(#icons)] -- Returns a random icon from the set
end

-- Function to shuffle the elements in a table
local function shuffle_table(tbl)
  local n = #tbl
  while n > 1 do
    local k = math.random(n)
    tbl[n], tbl[k] = tbl[k], tbl[n] -- Swap elements
    n = n - 1 -- Decrease the size of the unsorted portion
  end
end

-- Create a list of all icon sets to allow for random selection from any set
local icon_sets_list = {}
for _, icons in pairs(icon_sets) do
  table.insert(icon_sets_list, icons) -- Add each icon set to the list
end
shuffle_table(icon_sets_list) -- Shuffle the icon sets list

-- Function to reverse the order of elements in a table
local function reverse_table(tbl)
  local reversed = {}
  for i = #tbl, 1, -1 do
    table.insert(reversed, tbl[i]) -- Insert elements in reverse order
  end
  return reversed
end

-- Create a reversed list of icon sets
local reversed_icon_sets = reverse_table(icon_sets_list)

-- Function to create a separator component based on side (left/right) and optional mode color
local function create_separator(side, use_mode_color)
  return {
    function()
      return side == 'left' and '' or '' -- Choose separator symbol based on side
    end,
    color = function()
      -- Set color based on mode or opposite color
      local color = use_mode_color and get_mode_color() or get_opposite_color(get_mode_color())
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
local function create_mode_based_component(content, icon, color_fg, color_bg)
  return {
    content,
    icon = icon,
    color = function()
      local mode_color = get_mode_color()
      local opposite_color = get_opposite_color(mode_color)
      return {
        fg = color_fg or colors.FG,
        bg = color_bg or opposite_color,
        gui = 'bold',
      }
    end,
  }
end

-- -- Function to get the current mode indicator as a single character
local function mode()
  -- Map of modes to their respective shorthand indicators
  local mode_map = {
    n = 'N', -- Normal mode
    i = 'I', -- Insert mode
    v = 'V', -- Visual mode
    [''] = 'V', -- Visual block mode
    V = 'V', -- Visual line mode
    c = 'C', -- Command-line mode
    no = 'N', -- NInsert mode
    s = 'S', -- Select mode
    S = 'S', -- Select line mode
    ic = 'I', -- Insert mode (completion)
    R = 'R', -- Replace mode
    Rv = 'R', -- Virtual Replace mode
    cv = 'C', -- Command-line mode
    ce = 'C', -- Ex mode
    r = 'R', -- Prompt mode
    rm = 'M', -- More mode
    ['r?'] = '?', -- Confirm mode
    ['!'] = '!', -- Shell mode
    t = 'T', -- Terminal mode
  }
  -- Return the mode shorthand or [UNKNOWN] if no match
  return mode_map[vim.fn.mode()] or '[UNKNOWN]'
end

-- Config
local config = {
  options = {
    component_separators = '',
    section_separators = '',
    theme = {
      normal = {
        c = {
          fg = colors.FG,
          bg = colors.BG,
        },
      },
      inactive = {
        c = {
          fg = colors.FG,
          bg = colors.BG,
        },
      }, -- Simplified inactive theme
    },
    disabled_filetypes = {
      'neo-tree',
      'undotree',
      'sagaoutline',
      'diff',
    },
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {

        'location',
        color = function()
          return {
            fg = colors.FG,
            gui = 'bold',
          }
        end,
      },
    },
    lualine_x = {
      {
        'filename',
        color = function()
          return {
            fg = colors.FG,
            gui = 'bold,italic',
          }
        end,
      },
    },
    lualine_y = {},
    lualine_z = {},
  },
}

-- Helper functions
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

-- LEFT
ins_left {
  mode,
  color = function()
    local mode_color = get_mode_color()
    return {
      fg = colors.BG,
      bg = mode_color,
      gui = 'bold',
    }
  end,
  padding = { left = 1, right = 1 },
}

ins_left(create_separator('left', true))

ins_left {
  function()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
  end,
  icon = ' ',
  color = function()
    local virtual_env = vim.env.VIRTUAL_ENV
    if virtual_env then
      return {
        fg = get_mode_color(),
        gui = 'bold,strikethrough',
      }
    else
      return {
        fg = get_mode_color(),
        gui = 'bold',
      }
    end
  end,
}

ins_left(create_separator('right'))

ins_left(create_mode_based_component('filename', nil, colors.BG))

ins_left(create_separator('left'))

ins_left {
  function()
    return ''
  end,
  color = function()
    return {
      fg = get_middle_color(),
    }
  end,
  cond = hide_in_width,
}

ins_left {
  function()
    local git_status = vim.b.gitsigns_status_dict
    if git_status then
      return string.format('+%d ~%d -%d', git_status.added or 0, git_status.changed or 0, git_status.removed or 0)
    end
    return ''
  end,
  -- icon = '󰊢 ',
  color = {
    fg = colors.YELLOW,
    gui = 'bold',
  },
  cond = hide_in_width,
}

for _, icons in pairs(icon_sets_list) do
  ins_left {
    function()
      return get_random_icon(icons)
    end,
    color = function()
      return {
        fg = get_animated_color(),
      }
    end,
    cond = hide_in_width,
  }
end

ins_left {
  'searchcount',
  color = {
    fg = colors.GREEN,
    gui = 'bold',
  },
}

-- RIGHT
ins_right {
  function()
    local reg = vim.fn.reg_recording()
    return reg ~= '' and '[' .. reg .. ']' or ''
  end,
  color = {
    fg = '#ff3344',
    gui = 'bold',
  },
  cond = function()
    return vim.fn.reg_recording() ~= ''
  end,
}

ins_right {
  'selectioncount',
  color = {
    fg = colors.GREEN,
    gui = 'bold',
  },
}

for _, icons in ipairs(reversed_icon_sets) do
  ins_right {
    function()
      return get_random_icon(icons)
    end,
    color = function()
      return {
        fg = get_animated_color(),
      }
    end,
    cond = hide_in_width,
  }
end

ins_right {
  function()
    local msg = 'No Active Lsp'
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return msg
    end
    local lsp_short_names = {
      pyright = 'py',
      tsserver = 'ts',
      rust_analyzer = 'rs',
      lua_ls = 'lua',
      clangd = 'c++',
      bashls = 'sh',
      jsonls = 'json',
      html = 'html',
      cssls = 'css',
      tailwindcss = 'tw',
      dockerls = 'docker',
      sqlls = 'sql',
      yamlls = 'yml',
    }
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return lsp_short_names[client.name] or client.name:sub(1, 2)
      end
    end
    return msg
  end,
  icon = ' ',
  color = {
    fg = colors.YELLOW,
    gui = 'bold',
  },
}

ins_right {
  function()
    return ''
  end,
  color = function()
    return { fg = get_middle_color() }
  end,
  cond = hide_in_width,
}

ins_right(create_separator('right'))

ins_right(create_mode_based_component('location', nil, colors.BG))

ins_right(create_separator('left'))

ins_right {
  'branch',
  icon = ' ',
  --[[ Truncates and formats Git branch names for display in lualine:
    First segment: Uppercase, truncated to 1 character.
    Middle segments: Lowercase, truncated to 1 character.
    Last segment: Unchanged.
    Separator: › between truncated segments and the last segment.

    Example Input/Output:
		Branch										Name	Output
		backend/setup/tailwind		Bs›tailwind
		feature/add-ui						Fa›add-ui
		main											main
	]]
  fmt = function(branch)
    if branch == '' or branch == nil then
      return 'No Repo'
    end

    -- Function to truncate a segment to a specified length
    local function truncate_segment(segment, max_length)
      if #segment > max_length then
        return segment:sub(1, max_length)
      end
      return segment
    end

    -- Split the branch name by '/'
    local segments = {}
    for segment in branch:gmatch('[^/]+') do
      table.insert(segments, segment)
    end

    -- Truncate all segments except the last one
    for i = 1, #segments - 1 do
      segments[i] = truncate_segment(segments[i], 1) -- Truncate to 1 character
    end

    -- If there's only one segment (no '/'), return it as-is
    if #segments == 1 then
      return segments[1]
    end

    -- Capitalize the first segment and lowercase the rest (except the last one)
    segments[1] = segments[1]:upper() -- First segment uppercase
    for i = 2, #segments - 1 do
      segments[i] = segments[i]:lower() -- Other segments lowercase
    end

    -- Combine the first segments with no separator and add '›' before the last segment
    local truncated_branch = table.concat(segments, '', 1, #segments - 1) .. '›' .. segments[#segments]

    -- Ensure the final result doesn't exceed a maximum length
    local max_total_length = 15
    if #truncated_branch > max_total_length then
      truncated_branch = truncated_branch:sub(1, max_total_length) .. '…'
    end

    return truncated_branch
  end,
  color = function()
    local mode_color = get_mode_color()
    return {
      fg = mode_color,
      gui = 'bold',
    }
  end,
}

ins_right(create_separator('right'))

ins_right(create_mode_based_component('progress', nil, colors.BG))

require('lualine').setup(config)
