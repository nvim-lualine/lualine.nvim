-- inspired by kanagawa dragon theme for nvim
-- https://github.com/rebelot/kanagawa.nvim

local colors = {
  dragonBlack = '#0D0C0C',
  dragonGray = '#A6A69C',
  dragonLightGray = '#C5C9C5',
  dragonBackground = '#282727',
  dragonForeground = '#C8C093',
  dragonRed = '#C4746E',
  dragonGreen = '#87A987',
  dragonYellow = '#C4B28A',
  dragonBlue = '#8BA4B0',
  dragonOrange = '#B6927B',
  inactiveGray = '#625e5a',
}

local shared_sections = {
  b = { bg = colors.dragonBackground, fg = colors.dragonLightGray },
  c = { bg = colors.dragonBackground, fg = colors.dragonLightGray },
}

return {
  normal = vim.tbl_extend('force', {
    a = { bg = colors.dragonGray, fg = colors.dragonBlack, gui = 'bold' },
  }, shared_sections),

  insert = vim.tbl_extend('force', {
    a = { bg = colors.dragonRed, fg = colors.dragonBlack, gui = 'bold' },
  }, shared_sections),

  visual = vim.tbl_extend('force', {
    a = { bg = colors.dragonOrange, fg = colors.dragonBlack, gui = 'bold' },
  }, shared_sections),

  replace = vim.tbl_extend('force', {
    a = { bg = colors.dragonBlue, fg = colors.dragonBlack, gui = 'bold' },
  }, shared_sections),

  command = vim.tbl_extend('force', {
    a = { bg = colors.dragonGreen, fg = colors.dragonBlack, gui = 'bold' },
  }, shared_sections),

  inactive = {
    a = { bg = colors.inactiveGray, fg = colors.dragonGray, gui = 'bold' },
    b = { bg = colors.inactiveGray, fg = colors.dragonGray },
    c = { bg = colors.inactiveGray, fg = colors.dragonGray },
  },
}
