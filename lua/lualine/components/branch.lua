local git_branch

local known_git_dirs = {}
local sep = package.config:sub(1,1)

local function exists(path)
  local f = io.open(path)
  if not f then return false, false end
  local _, _, errno = f:read()
  return true, errno == 21 -- is a directory
end

local function find_git_dir()
  local file_path = vim.fn.expand('%:p:h')
  -- doen't show branch for terminal buffers
  if file_path:match('^term://.*$') then return nil end
  -- See if we already know where it is
  if known_git_dirs[file_path] then
    return known_git_dirs[file_path]
  end

  -- path seperator is not in the end add it
  local dir = file_path..sep
  -- do we need to iterate more than that?
  local n = 30
  while dir and n > 0 do
    n = n - 1
    local git_dir = dir..'.git'
    local is_available, is_directory = exists(git_dir)
    if is_available then
      if not is_directory then
        -- separate git-dir is used
        local git_file = io.open(git_dir)
        git_dir = git_file:read()
        git_dir = git_dir:match("gitdir: (.+)$")
      end
      -- store for reuse
      known_git_dirs[file_path] = git_dir
      return git_dir
    end
    dir = dir:match("(.*"..sep..").+$") -- "(.*/).+$"
  end
end

local function get_git_head()
  local git_dir = find_git_dir()
  if git_dir then
    local head_file = io.open(git_dir..sep..'HEAD')
    if head_file then
      local HEAD = head_file:read()
      local branch = HEAD:match('ref: refs/heads/(.+)$')
      if branch then return branch end
      return HEAD:sub(1,6)
    end
  end
  return ''
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
