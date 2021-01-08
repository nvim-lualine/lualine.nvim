local function fileformat()
  local ok, _ = pcall(require,'nvim-web-devicons')
  if ok then   
    local format = vim.bo.fileformat
    if format == 'unix' then return ""
    elseif format == 'dos' then return ""
    elseif format == 'mac' then return "" end
  end
  return [[%{&ff}]]
end

return fileformat
