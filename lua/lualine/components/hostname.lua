-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local modules = require('lualine_require').lazy_require {
  utils = 'lualine.utils.utils',
}
local uv = vim.uv or vim.loop

local function hostname()
  return modules.utils.stl_escape(uv.os_gethostname())
end

return hostname
