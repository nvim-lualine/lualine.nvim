-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local require = require('lualine_require').require
local get_mode = require('lualine.utils.mode').get_mode

local M = require('lualine.component'):extend()

M.update_status = get_mode

return M
