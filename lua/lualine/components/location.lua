-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local Location = require('lualine.component'):new()

Location.update_status = function()
  return [[%3l:%-2c]]
end

return Location
