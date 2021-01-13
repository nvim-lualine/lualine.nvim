-- =============================================================================
-- Filename: lua/lualine/themes/papercolor.lua
-- Author: shadman
-- Credit: itchyny(lightline)
-- License: MIT License
-- =============================================================================

local background = vim.o.background
print(background)

return require("lualine.themes.papercolor_"..background)
