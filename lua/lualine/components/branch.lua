local async = require('lualine.async')

local branch

local git_branch = async:new({
  cmd = 'git branch --show-current',
  on_stdout = function(_, data)
    if data then
      branch = data:gsub('\n', '')
    end
  end
})

local timer = vim.loop.new_timer()
timer:start(0, 1000, vim.schedule_wrap(function()
  git_branch:start()
end))

local function Branch()
  if not branch or #branch == 0 then return '' end
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
