-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()

M.update_status = vim.loop.os_gethostname

return M
