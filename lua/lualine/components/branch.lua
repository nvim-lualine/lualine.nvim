-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local utils = require('lualine.utils.utils')
local Branch = require('lualine.component'):new()
-- vars
Branch.git_branch = ''
-- os specific path separator
Branch.sep = package.config:sub(1, 1)
-- event watcher to watch head file
Branch.file_changed = vim.loop.new_fs_event()
Branch.active_bufnr = '0'
local branch_cache = {} -- stores last known branch for a buffer
-- Initilizer
Branch.new = function(self, options, child)
  local new_branch = self._parent:new(options, child or Branch)
  if not new_branch.options.icon then
    new_branch.options.icon = '' -- e0a0
  end
  -- run watch head on load so branch is present when component is loaded
  Branch.update_branch()
  -- update branch state of BufEnter as different Buffer may be on different repos
  utils.define_autocmd('BufEnter', "lua require'lualine.components.branch'.update_branch()")
  return new_branch
end

Branch.update_status = function(_, is_focused)
  if Branch.active_bufnr ~= vim.g.actual_curbuf then
    -- Workaround for https://github.com/hoob3rt/lualine.nvim/issues/286
    -- See upstream issue https://github.com/neovim/neovim/issues/15300
    -- Diff is out of sync re sync it.
    Branch.update_branch()
  end
  if not is_focused then return branch_cache[vim.fn.bufnr()] or '' end
  return Branch.git_branch
end

-- returns full path to git directory for current directory
function Branch.find_git_dir()
  -- get file dir so we can search from that dir
  local file_dir = vim.fn.expand('%:p:h')
  local git_file, git_dir
  -- Search upward for .git file or folder
  while (file_dir) do
    local git_path = file_dir..Branch.sep..'.git'
    local git_file_stat = vim.loop.fs_stat(git_path)
    if (git_file_stat) then
      if git_file_stat.type == 'directory' then
        git_dir = git_path
      elseif git_file_stat.type == 'file' then
        git_file = git_path
      end
      break
    end
    file_dir = file_dir:match('(.*)'..Branch.sep..'.-')
  end

  if git_file then
    -- separate git-dir or submodule is used
    local file = io.open(git_file)
    git_dir = file:read()
    git_dir = git_dir:match('gitdir: (.+)$')
    file:close()
    -- submodule / relative file path
    if git_dir:sub(1, 1) ~= Branch.sep and not git_dir:match('^%a:.*$') then
      git_dir = git_file:match('(.*).git') .. git_dir
    end
  end
  return git_dir
end

-- sets git_branch veriable to branch name or commit hash if not on branch
function Branch.get_git_head(head_file)
  local f_head = io.open(head_file)
  if f_head then
    local HEAD = f_head:read()
    f_head:close()
    local branch = HEAD:match('ref: refs/heads/(.+)$')
    if branch then
      Branch.git_branch = branch
    else
      Branch.git_branch = HEAD:sub(1, 6)
    end
  end
  return nil
end

-- Update branch
function Branch.update_branch()
  Branch.active_bufnr = tostring(vim.fn.bufnr())
  Branch.file_changed:stop()
  local git_dir = Branch.find_git_dir()
  if git_dir and #git_dir > 0 then
    local head_file = git_dir .. Branch.sep .. 'HEAD'
    Branch.get_git_head(head_file)
    Branch.file_changed:start(head_file, {}, vim.schedule_wrap(
                                  function()
          -- reset file-watch
          Branch.update_branch()
        end))
  else
    -- set to '' when git dir was not found
    Branch.git_branch = ''
  end
  branch_cache[vim.fn.bufnr()] = Branch.git_branch
end

return Branch
