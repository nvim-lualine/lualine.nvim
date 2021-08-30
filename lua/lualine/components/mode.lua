-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local require = require'lualine_require'.require
local Mode = require('lualine.component'):new()
local get_mode = require('lualine.utils.mode').get_mode

Mode.update_status = get_mode

return Mode
