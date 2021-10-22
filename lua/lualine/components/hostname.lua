-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function hostname()
  return vim.loop.os_gethostname()
end

return hostname
