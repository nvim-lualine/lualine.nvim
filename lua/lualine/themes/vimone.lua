-- =============================================================================
-- Filename: lua/lualine/themes/vimone.lua
-- Author: shadman
-- Credit: Zoltan Dalmadi(lightline)
-- License: MIT License
-- =============================================================================

local background = vim.o.background
print(background)

return require("lualine.themes.vimone_"..background)
