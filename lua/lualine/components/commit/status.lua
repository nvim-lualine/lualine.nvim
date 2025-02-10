local M = {}

local require = require('lualine_require').require
local utils = require('lualine.utils.utils')
local find_git_dir = require('lualine.components.commit.find_git_dir')
local RepoWatcher = require('lualine.components.commit.repo_watcher')

local git_repo_cache = {} -- Stores initialized RepoWatchers
local current_git_dir = '' -- Used to distinguish if the git_dir really changed

function M.watch_repo(dir_path)
  local git_dir = find_git_dir(dir_path)

  if git_dir == nil or current_git_dir == git_dir then
    return -- noting to do
  end

  -- Stop watching on all repos before watching new repository
  for _, v in pairs(git_repo_cache) do
    v:stop_watch()
  end
  local git_repo = git_repo_cache[git_dir]
  if git_repo == nil then
    git_repo = RepoWatcher:new(git_dir, {
      master_name = M.opts.master_name,
      fetch_interval = M.opts.fetch_interval,
      diff_against_master = M.opts.diff_against_master,
      findout_master_name = M.opts.findout_master_name,
    })
    git_repo_cache[git_dir] = git_repo
  else
    git_repo:restart_watch()
  end

  current_git_dir = git_dir
end

function M.init(opts)
  M.opts = opts
  M.watch_repo()
  utils.define_autocmd('BufEnter', "lua require'lualine.components.commit.status'.watch_repo()")
end

function M.status(bufnr)
  local file_dir
  if bufnr then
    local bufname = vim.fn.bufname(bufnr)
    file_dir = vim.fn.fnamemodify(bufname, ':p:h')
  else
    file_dir = vim.fn.expand('%:p:h')
  end

  local result = {}
  local git_dir = find_git_dir(file_dir)
  if git_dir == nil then
    return result
  end

  local repo = git_repo_cache[git_dir]
  if repo == nil then
    return result
  end

  table.insert(result, { repo.master_commit_count, repo.master_branch_conflict })
  table.insert(result, { repo.unpulled_commit_count, repo.unpushed_commit_count, repo.current_branch_conflict })
  return result
end

return M
