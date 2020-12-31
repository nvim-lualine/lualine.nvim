local function Branch()
  local branch = vim.fn.systemlist(
  'cd '..vim.fn.expand('%:p:h:S')..' 2>/dev/null && git status --porcelain -b 2>/dev/null')[1]
  if not branch or #branch == 0 then
    return ''
  end
  branch = branch:gsub([[^## No commits yet on (%w+)$]], '%1')
  branch = branch:gsub([[^##%s+(%w+).*$]], '%1')
  local ok,devicons = pcall(require,'nvim-web-devicons')
  if ok then
    local icon = devicons.get_icon('git')
    if icon ~= nil then
      return icon .. ' ' .. branch
    end
    return branch
  end
  ok = (vim.fn.exists('*WebDevIconsGetFileTypeSymbol'))
  if ok ~= 0 then
    local icon =  ''
    return icon .. ' ' .. branch
  end
  return branch
end

return Branch
