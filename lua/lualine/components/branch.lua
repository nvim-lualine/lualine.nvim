-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local git_branch

-- os specific path separator
local sep = package.config:sub(1, 1)

-- returns full path to git directory for current directory
local function find_git_dir()
  -- get file dir so we can search from that dir
  local file_dir = vim.fn.expand('%:p:h') .. ';'
  -- find .git/ folder genaral case
  local git_dir = vim.fn.finddir('.git', file_dir)
  -- find .git file in case of submodules or any other case git dir is in
  -- any other place than .git/
  local git_file = vim.fn.findfile('.git', file_dir)
  -- for some weird reason findfile gives relative path so expand it to fullpath
  if #git_file > 0 then git_file = vim.fn.fnamemodify(git_file, ':p') end
  if #git_file > #git_dir then
    -- separate git-dir or submodule is used
    local file = io.open(git_file)
    git_dir = file:read()
    git_dir = git_dir:match('gitdir: (.+)$')
    file:close()
    -- submodule / relative file path
    if git_dir:sub(1, 1) ~= sep and not git_dir:match('^%a:.*$') then
      git_dir = git_file:match('(.*).git') .. git_dir
    end
  end
  return git_dir
end

-- sets git_branch veriable to branch name or commit hash if not on branch
local function get_git_head(head_file)
  local f_head = io.open(head_file)
  if f_head then
    local HEAD = f_head:read()
    f_head:close()
    local branch = HEAD:match('ref: refs/heads/(.+)$')
    if branch then
      git_branch = branch
    else
      git_branch = HEAD:sub(1, 6)
    end
  end
  return nil
end

-- event watcher to watch head file
local file_changed = vim.loop.new_fs_event()
local function watch_head()
  file_changed:stop()
  local git_dir = find_git_dir()
  if #git_dir > 0 then
    local head_file = git_dir .. sep .. 'HEAD'
    get_git_head(head_file)
    file_changed:start(head_file, {}, vim.schedule_wrap(
                           function()
          -- reset file-watch
          watch_head()
        end))
  else
    -- set to nil when git dir was not found
    git_branch = nil
  end
end

local function branch(options)
  if not options.icon then
    options.icon = '' -- e0a0
  end

  return function()
    if not git_branch or #git_branch == 0 then return '' end
    return git_branch
  end
end

-- run watch head on load so branch is present when component is loaded
watch_head()

-- update branch state of BufEnter as different Buffer may be on different repos
vim.cmd [[autocmd BufEnter * lua require'lualine.components.branch'.lualine_branch_update()]]

return {
  init = function(options) return branch(options) end,
  lualine_branch_update = watch_head
}
