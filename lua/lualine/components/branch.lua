local async = require('lualine.async')

local git_branch

local get_git_branch = async:new({
  cmd = 'git branch --show-current',
  on_stdout = function(_, data)
    if data then
      git_branch = data:gsub('\n', '')
    end
  end
})

local timer = vim.loop.new_timer()
timer:start(0, 1000, vim.schedule_wrap(function()
  get_git_branch:start()
end))

local function branch()
  if not git_branch or #git_branch == 0 then return '' end
  local ok,devicons = pcall(require,'nvim-web-devicons')
  if ok then
    local icon = devicons.get_icon('git')
    if icon ~= nil then
      return icon .. ' ' .. git_branch
    end
    return git_branch
  end
  ok = (vim.fn.exists('*WebDevIconsGetFileTypeSymbol'))
  if ok ~= 0 then
    local icon =  ''
    return icon .. ' ' .. git_branch
  end
  return git_branch
end

return branch
