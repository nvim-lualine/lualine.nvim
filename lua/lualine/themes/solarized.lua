-- =============================================================================
-- Filename: lua/lualine/themes/solarized.lua
-- Author: shadman
-- Credit: itchyny(lightline)
-- License: MIT License
-- =============================================================================

local background = vim.o.background
print(background)

return require("lualine.themes.solarized_"..background)
