-- Simple yet useful config for lualine
-- Author: Bryant 
-- Credit: glepnir & shadmansaleh


local lualine = require 'lualine'

local colors = {
  bg            = '#232b2b',
  fg            = '#f8f8ff',
  red           = '#dd3e46',
  bred          = '#fc3235',
  blue          = '#4198c6',
  yellow        = '#dda654',
  byellow       = '#e8f402',
  green         = '#41c643',
  orange        = '#c67f41',
  cyan          = '#41c684',
  purple        = '#cd8fe0',
}

local function center()
  return '%='
end

-- Config
local config = {
  options = {
    component_separators = '',
    section_separators = '',
    theme = {
      normal = { c = { fg = colors.fg, bg = colors.bg } },
      inactive = { c = { fg = colors.fg, bg = colors.bg } },
    },
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_v = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
  extensions = {'nvim-tree'}
}

local function left(component)
  table.insert(config.sections.lualine_c, component)
end

local function right(component)
  table.insert(config.sections.lualine_x, component)
end

left {
  -- mode component
  function()
    -- auto change color according to neovims mode
    local mode_color = {
      n = colors.blue,
      i = colors.cyan,
      v = colors.yellow,
      V = colors.yellow,
    }
    vim.api.nvim_command('hi! LualineMode guifg=' .. mode_color[vim.fn.mode()] .. ' guibg=' .. colors.bg)
    return ''
  end,
  color = 'LualineMode',
  padding = { left = 1, right = 1 },
}

left {
  'branch',
  icon = '',
  fmt = string.upper,
  color = { fg = colors.fg, bg = colors.bg}
}

left {
  'diagnostics',
  sources = { 'nvim_lsp' },
  sections = { 'error', 'warn', 'info'},
  symbols = {error = ' ', warn = ' ', info = ' '},
  diagnostics_color = {
    color_error  = { fg = colors.bred },
    color_warn   = { fg = colors.byellow },
    color_info   = { fg = colors.bgreen },
  },
  always_visible = true,
  update_in_insert = true
}

right {
  'filename',
  file_status = true,
  shorting_target = 35,
  color = { fg = colors.purple }
}

right {
  'progress',
  color = { fg = colors.yellow }
}

-- Setup the config file~
lualine.setup(config)
