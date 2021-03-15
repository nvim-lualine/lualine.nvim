-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = {}

M.sections = {lualine_a = {'FugitiveHead'}, lualine_z = {'location'}}

M.inactive_sections = M.sections

M.filetypes = {'fugitive'}

return M
