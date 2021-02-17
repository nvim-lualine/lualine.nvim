-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local function encoding()
  local data = [[%{strlen(&fenc)?&fenc:&enc}]]
  return data
end

return encoding
