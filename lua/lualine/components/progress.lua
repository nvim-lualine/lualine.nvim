-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local Progress = require('lualine.component'):new()

Progress.update_status = function()
  return [[%3P]]
end

return Progress
