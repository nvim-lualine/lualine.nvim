-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function hostname()
  local data = vim.loop.os_gethostname()
  return data
end

return hostname
