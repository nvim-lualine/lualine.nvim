-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: itchyny(lightline)
-- License: MIT License
local background = vim.opt.background:get()

return require('lualine.themes.solarized_' .. background)
