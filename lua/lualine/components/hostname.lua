-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local HostName = require('lualine.component'):new()

HostName.update_status = vim.loop.os_gethostname

return HostName
