local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require {
  utils = 'lualine.utils.utils',
  Job = 'lualine.utils.job',
}

local M = {}

-- Vars
-- variable to store git diff stats
local git_diff = nil
-- accumulates output from diff process
local diff_output_cache = {}
-- variable to store git_diff job
local diff_job = nil

local active_bufnr = '0'
local diff_cache = {} -- Stores last known value of diff of a buffer

---initialize the module
---param opts table
function M.init(opts)
  if type(opts.source) == 'function' then
    M.src = opts.source
  else
    modules.utils.define_autocmd('BufEnter', "lua require'lualine.components.diff.git_diff'.update_diff_args()")
    modules.utils.define_autocmd('BufWritePost', "lua require'lualine.components.diff.git_diff'.update_git_diff()")
    M.update_diff_args()
  end
end

---Api to get git sign count
---scheme :
---{
---   added = added_count,
---   modified = modified_count,
---   removed = removed_count,
---}
---error_code = { added = -1, modified = -1, removed = -1 }
---@param bufnr number|nil
function M.get_sign_count(bufnr)
  if bufnr then
    return diff_cache[bufnr]
  end
  if M.src then
    git_diff = M.src()
    diff_cache[vim.api.nvim_get_current_buf()] = git_diff
  elseif vim.g.actual_curbuf ~= nil and active_bufnr ~= vim.g.actual_curbuf then
    -- Workaround for https://github.com/nvim-lualine/lualine.nvim/issues/286
    -- See upstream issue https://github.com/neovim/neovim/issues/15300
    -- Diff is out of sync re sync it.
    M.update_diff_args()
  end
  return git_diff
end

---process diff data and update git_diff{ added, removed, modified }
---@param data string output on stdout od git diff job
local function process_diff(data)
  -- Adapted from https://github.com/wbthomason/nvim-vcs.lua
  local added, removed, modified = 0, 0, 0
  for _, line in ipairs(data) do
    if string.find(line, [[^@@ ]]) then
      local tokens = vim.fn.matchlist(line, [[^@@ -\v(\d+),?(\d*) \+(\d+),?(\d*)]])
      local line_stats = {
        mod_count = tokens[3] == nil and 0 or tokens[3] == '' and 1 or tonumber(tokens[3]),
        new_count = tokens[5] == nil and 0 or tokens[5] == '' and 1 or tonumber(tokens[5]),
      }

      if line_stats.mod_count == 0 and line_stats.new_count > 0 then
        added = added + line_stats.new_count
      elseif line_stats.mod_count > 0 and line_stats.new_count == 0 then
        removed = removed + line_stats.mod_count
      else
        local min = math.min(line_stats.mod_count, line_stats.new_count)
        modified = modified + min
        added = added + line_stats.new_count - min
        removed = removed + line_stats.mod_count - min
      end
    end
  end
  git_diff = { added = added, modified = modified, removed = removed }
end

---updates the job args
function M.update_diff_args()
  -- Donn't show git diff when current buffer doesn't have a filename
  active_bufnr = tostring(vim.api.nvim_get_current_buf())
  if #vim.fn.expand('%') == 0 then
    M.diff_args = nil
    git_diff = nil
    return
  end
  M.diff_args = {
    cmd = string.format(
      [[git -C %s --no-pager diff --no-color --no-ext-diff -U0 -- %s]],
      vim.fn.expand('%:h'),
      vim.fn.expand('%:t')
    ),
    on_stdout = function(_, data)
      if next(data) then
        diff_output_cache = vim.list_extend(diff_output_cache, data)
      end
    end,
    on_stderr = function(_, data)
      data = table.concat(data, '\n')
      if #data > 0 then
        git_diff = nil
        diff_output_cache = {}
      end
    end,
    on_exit = function()
      if #diff_output_cache > 0 then
        process_diff(diff_output_cache)
      else
        git_diff = { added = 0, modified = 0, removed = 0 }
      end
      diff_cache[vim.api.nvim_get_current_buf()] = git_diff
    end,
  }
  M.update_git_diff()
end

---update git_diff veriable
function M.update_git_diff()
  if M.diff_args then
    diff_output_cache = {}
    if diff_job then
      diff_job:stop()
    end
    diff_job = modules.Job(M.diff_args)
    if diff_job then
      diff_job:start()
    end
  end
end

return M
