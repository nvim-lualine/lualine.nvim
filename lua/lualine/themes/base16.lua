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

local function setup_from_globals()
  -- Pull palette from base16-compatible globals.
  if vim.g.base16_gui00 and vim.g.base16_gui0F then
    return setup {
      bg = vim.g.base16_gui01,
      alt_bg = vim.g.base16_gui02,
      dark_fg = vim.g.base16_gui03,
      fg = vim.g.base16_gui04,
      light_fg = vim.g.base16_gui05,
      normal = vim.g.base16_gui0D,
      insert = vim.g.base16_gui0B,
      visual = vim.g.base16_gui0E,
      replace = vim.g.base16_gui09,
    }
  end

  -- Pull palette from tinted-vim globals.
  if vim.g.tinted_gui00 and vim.g.tinted_gui0F then
    return setup {
      bg = vim.g.tinted_gui01,
      alt_bg = vim.g.tinted_gui02,
      dark_fg = vim.g.tinted_gui03,
      fg = vim.g.tinted_gui04,
      light_fg = vim.g.tinted_gui05,
      normal = vim.g.tinted_gui0D,
      insert = vim.g.tinted_gui0B,
      visual = vim.g.tinted_gui0E,
      replace = vim.g.tinted_gui09,
    }
  end
  return nil
end

return setup_from_globals()
