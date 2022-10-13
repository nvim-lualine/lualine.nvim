local function searchcount()
  if vim.v.hlsearch == 0 then
    return ""
  end

  local result = vim.fn.searchcount()
  local denominator = math.min(result.total, result.maxcount)
  return string.format("[%d/%d]", result.current, denominator)
end

return searchcount
