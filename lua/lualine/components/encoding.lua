-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function encoding()
  return [[%{strlen(&fenc)?&fenc:&enc}]]
end

return encoding
