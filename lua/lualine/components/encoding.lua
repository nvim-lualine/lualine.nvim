local function Encoding()
  local encoding = [[%{strlen(&fenc)?&fenc:&enc}]]
  return encoding
end

return Encoding
