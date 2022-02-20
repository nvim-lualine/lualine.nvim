-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
-- Credit: itchyny(lightline)
-- License: MIT License
local background = vim.opt.background:get()
local style = vim.g.ayucolor or ((background == 'dark') and vim.g.ayuprefermirage and 'mirage' or background)

return require('lualine.themes.ayu_' .. style)
