local async = require('lualine.async')

local git_branch

local get_git_branch = async:new({
  cmd = 'git branch --show-current',
  on_stdout = function(_, data)
    if data then
      git_branch = data:gsub('\n', '')
    end
  end,
  on_stderr = function (_, data)
    if data then
      if data:find("fatal: not a git repository") then
        git_branch = ''
      end
    end
  end,
})

local timer = vim.loop.new_timer()
timer:start(0, 1000, vim.schedule_wrap(function()
  local cur_dir = vim.fn.getcwd()
  local buffer_working_directory = vim.fn.expand("%:p:h")
  local status, _ = pcall(vim.api.nvim_set_current_dir, buffer_working_directory)
  if status == true then
    get_git_branch:start()
    vim.api.nvim_set_current_dir(cur_dir)
  end
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
  ok = vim.fn.exists("*WebDevIconsGetFileTypeSymbol")
  if ok ~= 0 then
    local icon =  ''
    return icon .. ' ' .. git_branch
  end
  return git_branch
end

return branch
