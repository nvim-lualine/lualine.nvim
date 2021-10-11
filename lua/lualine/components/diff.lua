-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local lualine_require = require 'lualine_require'
local modules = lualine_require.lazy_require {
  utils = 'lualine.utils.utils',
  utils_notices = 'lualine.utils.notices',
  highlight = 'lualine.highlight',
  Job = 'lualine.utils.job',
}
local M = lualine_require.require('lualine.component'):extend()

-- Vars
-- variable to store git diff stats
M.git_diff = nil
-- accumulates output from diff process
M.diff_output_cache = {}
-- variable to store git_diff job
M.diff_job = nil
M.active_bufnr = '0'

local diff_cache = {} -- Stores last known value of diff of a buffer

local default_options = {
  colored = true,
  symbols = { added = '+', modified = '~', removed = '-' },
  diff_color = {
    added = {
      fg = modules.utils.extract_highlight_colors('DiffAdd', 'fg') or '#f0e130',
    },
    modified = {
      fg = modules.utils.extract_highlight_colors('DiffChange', 'fg') or '#ff0038',
    },
    removed = {
      fg = modules.utils.extract_highlight_colors('DiffDelete', 'fg') or '#ff0038',
    },
  },
}

-- Initializer
function M:init(options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  -- create highlights and save highlight_name in highlights table
  if self.options.colored then
    self.highlights = {
      added = modules.highlight.create_component_highlight_group(
        self.options.diff_color.added,
        'diff_added',
        self.options
      ),
      modified = modules.highlight.create_component_highlight_group(
        self.options.diff_color.modified,
        'diff_modified',
        self.options
      ),
      removed = modules.highlight.create_component_highlight_group(
        self.options.diff_color.removed,
        'diff_removed',
        self.options
      ),
    }
  end

  M.diff_checker_enabled = type(self.options.source) ~= 'function'

  if M.diff_checker_enabled then
    -- setup internal source
    modules.utils.define_autocmd('BufEnter', "lua require'lualine.components.diff'.update_diff_args()")
    modules.utils.define_autocmd('BufWritePost', "lua require'lualine.components.diff'.update_git_diff()")
    M.update_diff_args()
  end
end

-- Function that runs everytime statusline is updated
function M:update_status(is_focused)
  local git_diff
  if M.diff_checker_enabled then
    if M.active_bufnr ~= vim.g.actual_curbuf then
      -- Workaround for https://github.com/hoob3rt/lualine.nvim/issues/286
      -- See upstream issue https://github.com/neovim/neovim/issues/15300
      -- Diff is out of sync re sync it.
      M.update_diff_args()
    end
    git_diff = M.git_diff
  else
    git_diff = self.options.source()
  end

  if not is_focused then
    git_diff = diff_cache[vim.fn.bufnr()] or {}
  end
  if git_diff == nil then
    return ''
  end

  local colors = {}
  if self.options.colored then
    -- load the highlights and store them in colors table
    for name, highlight_name in pairs(self.highlights) do
      colors[name] = modules.highlight.component_format_highlight(highlight_name)
    end
  end

  local result = {}
  -- loop though data and load available sections in result table
  for _, name in ipairs { 'added', 'modified', 'removed' } do
    if git_diff[name] and git_diff[name] > 0 then
      if self.options.colored then
        table.insert(result, colors[name] .. self.options.symbols[name] .. git_diff[name])
      else
        table.insert(result, self.options.symbols[name] .. git_diff[name])
      end
    end
  end
  if #result > 0 then
    return table.concat(result, ' ')
  else
    return ''
  end
end

-- Api to get git sign count
-- scheme :
-- {
--    added = added_count,
--    modified = modified_count,
--    removed = removed_count,
-- }
-- error_code = { added = -1, modified = -1, removed = -1 }
function M.get_sign_count()
  if M.diff_checker_enabled then
    M.update_diff_args()
  end
  return M.git_diff or { added = -1, modified = -1, removed = -1 }
end

-- process diff data and update git_diff{ added, removed, modified }
function M.process_diff(data)
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
  M.git_diff = { added = added, modified = modified, removed = removed }
end

-- Updates the job args
function M.update_diff_args()
  -- Donn't show git diff when current buffer doesn't have a filename
  M.active_bufnr = tostring(vim.fn.bufnr())
  if #vim.fn.expand '%' == 0 then
    M.diff_args = nil
    M.git_diff = nil
    return
  end
  M.diff_args = {
    cmd = string.format(
      [[git -C %s --no-pager diff --no-color --no-ext-diff -U0 -- %s]],
      vim.fn.expand '%:h',
      vim.fn.expand '%:t'
    ),
    on_stdout = function(_, data)
      if next(data) then
        M.diff_output_cache = vim.list_extend(M.diff_output_cache, data)
      end
    end,
    on_stderr = function(_, data)
      data = table.concat(data, '\n')
      if #data > 1 or (#data == 1 and #data[1] > 0) then
        M.git_diff = nil
        M.diff_output_cache = {}
      end
    end,
    on_exit = function()
      if #M.diff_output_cache > 0 then
        M.process_diff(M.diff_output_cache)
      else
        M.git_diff = { added = 0, modified = 0, removed = 0 }
      end
      diff_cache[vim.fn.bufnr()] = M.git_diff
    end,
  }
  M.update_git_diff()
end

-- Update git_diff veriable
function M.update_git_diff()
  if M.diff_args then
    M.diff_output_cache = {}
    if M.diff_job then
      M.diff_job:stop()
    end
    M.diff_job = modules.Job(M.diff_args)
    if M.diff_job then
      M.diff_job:start()
    end
  end
end

return M
