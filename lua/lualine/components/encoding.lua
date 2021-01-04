local function encoding()
  local data = [[%{strlen(&fenc)?&fenc:&enc}]]
  return data
end

return encoding
