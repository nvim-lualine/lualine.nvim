local M = {}

local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require {
  utils = 'lualine.utils.utils',
  Job = 'lualine.utils.job',
}

-- vars
local current_git_branch = ''
local current_git_dir = ''
local current_git_dir_is_reftable = false
local branch_cache = {} -- stores last known branch for a buffer
local active_bufnr = '0'
-- os specific path separator
local sep = package.config:sub(1, 1)
-- event watcher to watch head file
-- Use file watch for non Windows and poll for Windows.
-- Windows doesn't like file watch for some reason.
local file_changed = sep ~= '\\' and vim.loop.new_fs_event() or vim.loop.new_fs_poll()
local git_dir_cache = {} -- Stores git paths that we already know of
---job handle for async git commands (reftable repos)
local branch_job = nil

---checks if git directory uses reftable format
---@param git_dir string full path to .git directory
---@return boolean
local function is_reftable_repo(git_dir)
  local reftable_dir = git_dir .. sep .. 'reftable'
  local stat = vim.loop.fs_stat(reftable_dir)
  return stat ~= nil and stat.type == 'directory'
end

---sets git_branch variable to branch name or commit hash if not on branch
---@param head_file string full path of .git/HEAD file
local function get_git_head(head_file)
  local f_head = io.open(head_file)
  if f_head then
    local HEAD = f_head:read()
    f_head:close()
    local branch = HEAD:match('ref: refs/heads/(.+)$')
    if branch then
      current_git_branch = branch
    else
      current_git_branch = HEAD:sub(1, 6)
    end
  end
  return nil
end

---gets short commit hash for detached HEAD in reftable repos (async)
---@param git_dir string full path to .git directory
---@param bufnr number buffer number to update cache for
local function get_branch_reftable_hash(git_dir, bufnr)
  if branch_job then
    branch_job:stop()
  end

  local output = {}
  branch_job = modules.Job {
    cmd = { 'git', '--git-dir=' .. git_dir, 'rev-parse', '--short', 'HEAD' },
    on_stdout = function(_, data)
      if data then
        output = vim.list_extend(output, data)
      end
    end,
    on_exit = function(_, code)
      if code == 0 and #output > 0 then
        current_git_branch = vim.trim(table.concat(output, ''))
      else
        current_git_branch = ''
      end
      branch_cache[bufnr] = current_git_branch
    end,
  }
  branch_job:start()
end

---gets branch name for reftable repos using git command (async)
---@param git_dir string full path to .git directory
---@param bufnr number buffer number to update cache for
local function get_branch_reftable(git_dir, bufnr)
  if branch_job then
    branch_job:stop()
  end

  local output = {}
  branch_job = modules.Job {
    cmd = { 'git', '--git-dir=' .. git_dir, 'symbolic-ref', '--short', 'HEAD' },
    on_stdout = function(_, data)
      if data then
        output = vim.list_extend(output, data)
      end
    end,
    on_exit = function(_, code)
      if code == 0 and #output > 0 then
        local branch = vim.trim(table.concat(output, ''))
        if #branch > 0 then
          current_git_branch = branch
          branch_cache[bufnr] = current_git_branch
          return
        end
      end
      -- Detached HEAD or error - try rev-parse for short commit hash
      get_branch_reftable_hash(git_dir, bufnr)
    end,
  }
  branch_job:start()
end

---updates the current value of git_branch and sets up file watch on HEAD file
local function update_branch()
  local bufnr = vim.api.nvim_get_current_buf()
  active_bufnr = tostring(bufnr)
  file_changed:stop()
  local git_dir = current_git_dir
  if git_dir and #git_dir > 0 then
    local watch_file
    if current_git_dir_is_reftable then
      -- Reftable format: use git command to get branch name
      get_branch_reftable(git_dir, bufnr)
      watch_file = git_dir .. sep .. 'reftable' .. sep .. 'tables.list'
    else
      -- Normal git format: read HEAD file directly
      local head_file = git_dir .. sep .. 'HEAD'
      get_git_head(head_file)
      watch_file = head_file
    end
    file_changed:start(
      watch_file,
      sep ~= '\\' and {} or 1000,
      vim.schedule_wrap(function()
        -- reset file-watch
        update_branch()
      end)
    )
  else
    -- set to '' when git dir was not found
    current_git_branch = ''
  end
  branch_cache[bufnr] = current_git_branch
end

---updates the current value of current_git_branch and sets up file watch on HEAD file if value changed
local function update_current_git_dir(git_dir)
  if current_git_dir ~= git_dir then
    current_git_dir = git_dir
    current_git_dir_is_reftable = git_dir and is_reftable_repo(git_dir) or false
    update_branch()
  end
end

---returns full path to git directory for dir_path or current directory
---@param dir_path string|nil
---@return string|nil
function M.find_git_dir(dir_path)
  local git_dir = vim.env.GIT_DIR
  if git_dir then
    update_current_git_dir(git_dir)
    return git_dir
  end

  -- get file dir so we can search from that dir
  local file_dir = dir_path or vim.fn.expand('%:p:h')

  if package.loaded.oil then
    local oil = require('oil')
    local ok, dir = pcall(oil.get_current_dir)
    if ok and dir and dir ~= '' then
      file_dir = vim.fn.fnamemodify(dir, ':p:h')
    end
  end

  -- extract correct file dir from terminals
  if file_dir and file_dir:match('term://.*') then
    file_dir = vim.fn.expand(file_dir:gsub('term://(.+)//.+', '%1'))
  end

  local root_dir = file_dir
  -- Search upward for .git file or folder
  while root_dir do
    if git_dir_cache[root_dir] then
      git_dir = git_dir_cache[root_dir]
      break
    end
    local git_path = root_dir .. sep .. '.git'
    local git_file_stat = vim.loop.fs_stat(git_path)
    if git_file_stat then
      if git_file_stat.type == 'directory' then
        git_dir = git_path
      elseif git_file_stat.type == 'file' then
        -- separate git-dir or submodule is used
        local file = io.open(git_path)
        if file then
          git_dir = file:read()
          git_dir = git_dir and git_dir:match('gitdir: (.+)$')
          file:close()
        end
        -- submodule / relative file path
        if git_dir and git_dir:sub(1, 1) ~= sep and not git_dir:match('^%a:.*$') then
          git_dir = git_path:match('(.*).git') .. git_dir
        end
      end
      if git_dir then
        -- Check for traditional HEAD file or reftable format
        local head_file_stat = vim.loop.fs_stat(git_dir .. sep .. 'HEAD')
        if head_file_stat and head_file_stat.type == 'file' then
          break
        end
        -- Also accept reftable repos (they may not have a traditional HEAD file)
        local reftable_stat = vim.loop.fs_stat(git_dir .. sep .. 'reftable' .. sep .. 'tables.list')
        if reftable_stat and reftable_stat.type == 'file' then
          break
        end
        git_dir = nil
      end
    end
    root_dir = root_dir:match('(.*)' .. sep .. '.-')
  end

  git_dir_cache[file_dir] = git_dir
  if dir_path == nil then
    update_current_git_dir(git_dir)
  end
  return git_dir
end

---initializes git_branch module
function M.init()
  -- run watch head on load so branch is present when component is loaded
  M.find_git_dir()
  -- update branch state of BufEnter as different Buffer may be on different repos
  modules.utils.define_autocmd('BufEnter', "lua require'lualine.components.branch.git_branch'.find_git_dir()")
end
function M.get_branch(bufnr)
  if vim.g.actual_curbuf ~= nil and active_bufnr ~= vim.g.actual_curbuf then
    -- Workaround for https://github.com/nvim-lualine/lualine.nvim/issues/286
    -- See upstream issue https://github.com/neovim/neovim/issues/15300
    -- Diff is out of sync re sync it.
    M.find_git_dir()
  end
  if bufnr then
    return branch_cache[bufnr] or ''
  else
    branch_cache[vim.api.nvim_get_current_buf()] = current_git_branch
  end
  return current_git_branch
end

return M
