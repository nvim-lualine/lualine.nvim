-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()
local modules = require('lualine_require').lazy_require {
  utils = 'lualine.utils.utils',
}
-- vars
M.git_branch = ''
M.git_dir = ''
-- os specific path separator
M.sep = package.config:sub(1, 1)
-- event watcher to watch head file
-- Use file wstch for non windows and poll for windows.
-- windows doesn't like file watch for some reason.
M.file_changed = M.sep ~= '\\' and vim.loop.new_fs_event() or vim.loop.new_fs_poll()
M.active_bufnr = '0'
local branch_cache = {} -- stores last known branch for a buffer
-- Initilizer
M.init = function(self, options)
  M.super.init(self, options)
  if not self.options.icon then
    self.options.icon = '' -- e0a0
  end
  -- run watch head on load so branch is present when component is loaded
  M.find_git_dir()
  -- update branch state of BufEnter as different Buffer may be on different repos
  modules.utils.define_autocmd('BufEnter', "lua require'lualine.components.branch'.find_git_dir()")
end

M.update_status = function(_, is_focused)
  if M.active_bufnr ~= vim.g.actual_curbuf then
    -- Workaround for https://github.com/hoob3rt/lualine.nvim/issues/286
    -- See upstream issue https://github.com/neovim/neovim/issues/15300
    -- Diff is out of sync re sync it.
    M.find_git_dir()
  end
  if not is_focused then
    return branch_cache[vim.fn.bufnr()] or ''
  end
  return M.git_branch
end

local git_dir_cache = {} -- Stores git paths that we already know of
-- returns full path to git directory for current directory
function M.find_git_dir()
  -- get file dir so we can search from that dir
  local file_dir = vim.fn.expand '%:p:h'
  local root_dir = file_dir
  local git_dir
  -- Search upward for .git file or folder
  while root_dir do
    if git_dir_cache[root_dir] then
      git_dir = git_dir_cache[root_dir]
      break
    end
    local git_path = root_dir .. M.sep .. '.git'
    local git_file_stat = vim.loop.fs_stat(git_path)
    if git_file_stat then
      if git_file_stat.type == 'directory' then
        git_dir = git_path
      elseif git_file_stat.type == 'file' then
        -- separate git-dir or submodule is used
        local file = io.open(git_path)
        git_dir = file:read()
        git_dir = git_dir:match 'gitdir: (.+)$'
        file:close()
        -- submodule / relative file path
        if git_dir and git_dir:sub(1, 1) ~= M.sep and not git_dir:match '^%a:.*$' then
          git_dir = git_path:match '(.*).git' .. git_dir
        end
      end
      if git_dir then
        local head_file_stat = vim.loop.fs_stat(git_dir .. M.sep .. 'HEAD')
        if head_file_stat and head_file_stat.type == 'file' then
          break
        else
          git_dir = nil
        end
      end
    end
    root_dir = root_dir:match('(.*)' .. M.sep .. '.-')
  end

  git_dir_cache[file_dir] = git_dir
  if M.git_dir ~= git_dir then
    M.git_dir = git_dir
    M.update_branch()
  end
  return git_dir
end

-- sets git_branch veriable to branch name or commit hash if not on branch
function M.get_git_head(head_file)
  local f_head = io.open(head_file)
  if f_head then
    local HEAD = f_head:read()
    f_head:close()
    local branch = HEAD:match 'ref: refs/heads/(.+)$'
    if branch then
      M.git_branch = branch
    else
      M.git_branch = HEAD:sub(1, 6)
    end
  end
  return nil
end

-- Update branch
function M.update_branch()
  M.active_bufnr = tostring(vim.fn.bufnr())
  M.file_changed:stop()
  local git_dir = M.git_dir
  if git_dir and #git_dir > 0 then
    local head_file = git_dir .. M.sep .. 'HEAD'
    M.get_git_head(head_file)
    M.file_changed:start(
      head_file,
      M.sep ~= '\\' and {} or 1000,
      vim.schedule_wrap(function()
        -- reset file-watch
        M.update_branch()
      end)
    )
  else
    -- set to '' when git dir was not found
    M.git_branch = ''
  end
  branch_cache[vim.fn.bufnr()] = M.git_branch
end

return M
