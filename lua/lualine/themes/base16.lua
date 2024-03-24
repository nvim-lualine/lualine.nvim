local modules = require('lualine_require').lazy_require { notices = 'lualine.utils.notices' }

local function add_notice(notice)
  modules.notices.add_notice('theme(base16): ' .. notice)
end

local function setup(colors)
  local theme = {
    normal = {
      a = { fg = colors.bg, bg = colors.normal },
      b = { fg = colors.light_fg, bg = colors.alt_bg },
      c = { fg = colors.fg, bg = colors.bg },
    },
    replace = {
      a = { fg = colors.bg, bg = colors.replace },
      b = { fg = colors.light_fg, bg = colors.alt_bg },
    },
    insert = {
      a = { fg = colors.bg, bg = colors.insert },
      b = { fg = colors.light_fg, bg = colors.alt_bg },
    },
    visual = {
      a = { fg = colors.bg, bg = colors.visual },
      b = { fg = colors.light_fg, bg = colors.alt_bg },
    },
    inactive = {
      a = { fg = colors.dark_fg, bg = colors.bg },
      b = { fg = colors.dark_fg, bg = colors.bg },
      c = { fg = colors.dark_fg, bg = colors.bg },
    },
  }

  theme.command = theme.normal
  theme.terminal = theme.insert

  return theme
end

local function setup_base16()
  local loaded, base16 = pcall(require, 'base16-colorscheme')

  if not loaded then
    add_notice(
      'nvim-base16 is not currently present in your runtimepath. If this is unintended, make sure it is properly installed.'
    )

    error('nvim-base16 is not currently present in your runtimepath, make sure it is properly installed.')
  end

  if not base16.colors and not vim.env.BASE16_THEME then
    add_notice(
      'nvim-base16 is not loaded yet, you should update your configuration to load it before lualine'
        .. ' so that the colors from your colorscheme can be used.'
    )

    error(
      'nvim-base16 is not loaded yet, you should update your configuration to load it before lualine'
        .. ' so that the colors from your colorscheme can be used.'
    )
  elseif not base16.colors and not base16.colorschemes[vim.env.BASE16_THEME] then
    add_notice(
      'The colorscheme "%s" defined by the environment variable "BASE16_THEME" is not handled by' .. ' nvim-base16.'
    )

    error(
      'The colorscheme "%s" defined by the environment variable "BASE16_THEME" is not handled by' .. ' nvim-base16.'
    )
  end

  local colors = base16.colors or base16.colorschemes[vim.env.BASE16_THEME]

  return setup {
    bg = colors.base01,
    alt_bg = colors.base02,
    dark_fg = colors.base03,
    fg = colors.base04,
    light_fg = colors.base05,
    normal = colors.base0D,
    insert = colors.base0B,
    visual = colors.base0E,
    replace = colors.base09,
  }
end

return setup_base16()
