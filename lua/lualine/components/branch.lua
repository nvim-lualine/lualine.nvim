local git_branch

local known_git_dirs = {}
local sep = package.config:sub(1,1)

local function exists(path)
  local f = io.open(path)
  if not f then return false, false end
  local _, _, errno = f:read()
  f:close()
  return true, errno == 21 -- is a directory
end

local function find_git_dir()
  -- path seperator is not in the end add it
  local file_path = vim.fn.expand('%:p:h')..sep
  -- don't show branch for terminal buffers
  if file_path:match('^term://.*$') then return nil end

  local dir = file_path
  -- do we need to iterate more than that?
  local n = 30
  while dir and n > 0 do
    n = n - 1
    -- See if we already know where it is
    if known_git_dirs[dir] then
      if dir ~= file_path then
        -- store it if file_path is a sub directory of dir
        known_git_dirs[file_path] = known_git_dirs[dir] end
      return known_git_dirs[dir]
    end
    local git_dir = dir..'.git'
    local is_available, is_directory = exists(git_dir)
    if is_available then
      if not is_directory then
        -- separate git-dir is used
        local git_file = io.open(git_dir)
        git_dir = git_file:read()
        git_dir = git_dir:match("gitdir: (.+)$")
        git_dir:close()
      end
      -- store for reuse
      known_git_dirs[file_path] = git_dir
      return git_dir
    end
    dir = dir:match("(.*"..sep..").+$") -- "(.*/).+$"
  end
  return nil
end

local function get_git_head()
  local git_dir = find_git_dir()
  if git_dir then
    local head_file = io.open(git_dir..sep..'HEAD')
    if head_file then
      local HEAD = head_file:read()
      local branch = HEAD:match('ref: refs/heads/(.+)$')
      head_file:close()
      if branch then return branch end
      return HEAD:sub(1,6)
    end
  end
  return nil
end

local timer = vim.loop.new_timer()
timer:start(0, 1000, vim.schedule_wrap(function()
  git_branch = get_git_head()
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
