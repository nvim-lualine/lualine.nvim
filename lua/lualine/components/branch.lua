local git_branch

-- os specific path separator
local sep = package.config:sub(1,1)

local function exists(path)
  local f = io.open(path)
  if not f then return false, false end
  local _, _, errno = f:read()
  f:close()
  return true, errno == 21 -- is a directory
end

local function find_git_dir()
  -- path separator is not in the end add it
  local dir = vim.fn.expand('%:p:h')..sep
  -- don't show branch for terminal buffers
  if dir:match('^term://.*$') then return nil end

  -- do we need to iterate more than that?
  local iteration_count = 30
  while dir and iteration_count > 0 do
    iteration_count = iteration_count - 1
    local git_dir = dir..'.git'
    local is_available, is_directory = exists(git_dir)
    if is_available then
      if not is_directory then
        -- separate git-dir or submodule is used
        local git_file = io.open(git_dir)
        git_dir = git_file:read()
        git_dir = git_dir:match("gitdir: (.+)$")
        git_file:close()
        -- submodule / relative file path
        if git_dir:sub(1,1) ~= sep and not git_dir:match('^%a:.*$') then
          git_dir = dir..git_dir
        end
      end
      return git_dir
    end
    dir = dir:match("(.*"..sep..").+$") -- "(.*/).+$"
  end
  return nil
end

local function get_git_head(head_file)
  local f_head = io.open(head_file)
  if f_head then
    local HEAD = f_head:read()
    f_head:close()
    local branch = HEAD:match('ref: refs/heads/(.+)$')
    if branch then git_branch = branch
    else git_branch =  HEAD:sub(1,6) end
  end
  return nil
end

local file_changed = vim.loop.new_fs_event()
local function watch_head()
  file_changed:stop()
  local git_dir = find_git_dir()
  if git_dir then
    local head_file = git_dir..sep..'HEAD'
    get_git_head(head_file)
    file_changed:start(head_file, {}, vim.schedule_wrap(function()
      watch_head()
    end))
  else
    git_branch = nil
  end
end

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

watch_head()
_G.lualine_branch_update = watch_head
vim.cmd[[autocmd BufEnter * call v:lua.lualine_branch_update()]]

return branch
