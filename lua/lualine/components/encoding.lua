-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local Encoding = require('lualine.component'):new()

Encoding.update_status = function() return [[%{strlen(&fenc)?&fenc:&enc}]] end

return Encoding
