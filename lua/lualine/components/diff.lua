-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local utils = require 'lualine.utils.utils'
local highlight = require 'lualine.highlight'
local Job = require'lualine.utils.job'

local Diff = require('lualine.component'):new()

-- Vars
-- variable to store git diff stats
Diff.git_diff = nil
-- accumulates output from diff process
Diff.diff_output_cache = {}
-- variable to store git_diff job
Diff.diff_job = nil
-- default colors
Diff.default_colors = {
  added = '#f0e130',
  removed = '#90ee90',
  modified = '#ff0038'
}

local diff_cache = {} -- Stores last known value of diff of a buffer

-- Initializer
Diff.new = function(self, options, child)
  local new_instance = self._parent:new(options, child or Diff)
  local default_symbols = {added = '+', modified = '~', removed = '-'}
  new_instance.options.symbols = vim.tbl_extend('force', default_symbols,
                                                new_instance.options.symbols or
                                                    {})
  if new_instance.options.colored == nil then
    new_instance.options.colored = true
  end
  -- apply colors
  if not new_instance.options.color_added then
    new_instance.options.color_added = utils.extract_highlight_colors('DiffAdd',
                                                                      'fg') or
                                           Diff.default_colors.added
  end
  if not new_instance.options.color_modified then
    new_instance.options.color_modified =
        utils.extract_highlight_colors('DiffChange', 'fg') or
            Diff.default_colors.modified
  end
  if not new_instance.options.color_removed then
    new_instance.options.color_removed =
        utils.extract_highlight_colors('DiffDelete', 'fg') or
            Diff.default_colors.removed
  end

  -- create highlights and save highlight_name in highlights table
  if new_instance.options.colored then
    new_instance.highlights = {
      added = highlight.create_component_highlight_group(
          {fg = new_instance.options.color_added}, 'diff_added',
          new_instance.options),
      modified = highlight.create_component_highlight_group(
          {fg = new_instance.options.color_modified}, 'diff_modified',
          new_instance.options),
      removed = highlight.create_component_highlight_group(
          {fg = new_instance.options.color_removed}, 'diff_removed',
          new_instance.options)
    }
  end

  if type(new_instance.options.source) ~= 'function' then
    -- setup internal source
    utils.define_autocmd('BufEnter', "lua require'lualine.components.diff'.update_diff_args()")
    utils.define_autocmd('BufWritePost', "lua require'lualine.components.diff'.update_git_diff()")
  end

  return new_instance
end

-- Function that runs everytime statusline is updated
Diff.update_status = function(self, is_focused)
  local git_diff = Diff.git_diff
  if self.options.source then
    git_diff = self.options.source()
  end

  if not is_focused then git_diff = diff_cache[vim.fn.bufnr()] or {} end
  if git_diff == nil then return '' end

  local colors = {}
  if self.options.colored then
    -- load the highlights and store them in colors table
    for name, highlight_name in pairs(self.highlights) do
      colors[name] = highlight.component_format_highlight(highlight_name)
    end
  end

  local result = {}
  -- loop though data and load available sections in result table
  for _, name in ipairs {'added', 'modified', 'removed'} do
    if git_diff[name] and git_diff[name] > 0 then
      if self.options.colored then
        table.insert(result, colors[name] .. self.options.symbols[name] ..
                         git_diff[name])
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
function Diff.get_sign_count()
  Diff.update_diff_args()
  Diff.update_git_diff()
  return Diff.git_diff or {added = -1, modified = -1, removed = -1}
end

-- process diff data and update git_diff{ added, removed, modified }
function Diff.process_diff(data)
  -- Adapted from https://github.com/wbthomason/nvim-vcs.lua
  local added, removed, modified = 0, 0, 0
  for _, line in ipairs(data) do
    if string.find(line, [[^@@ ]]) then
      local tokens = vim.fn.matchlist(line,
                                      [[^@@ -\v(\d+),?(\d*) \+(\d+),?(\d*)]])
      local line_stats = {
        mod_count = tokens[3] == '' and 1 or tonumber(tokens[3]),
        new_count = tokens[5] == '' and 1 or tonumber(tokens[5])
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
  Diff.git_diff = {added = added, modified = modified, removed = removed}
end

-- Updates the job args
function Diff.update_diff_args()
  -- Donn't show git diff when current buffer doesn't have a filename
  if #vim.fn.expand('%') == 0 then
    Diff.diff_args = nil;
    Diff.git_diff = nil;
    return
  end
  Diff.diff_args = {
    cmd = string.format(
        [[git -C %s --no-pager diff --no-color --no-ext-diff -U0 -- %s]],
        vim.fn.expand('%:h'), vim.fn.expand('%:t')),
    on_stdout = function(_, data)
      if next(data) then
        Diff.diff_output_cache = vim.list_extend(Diff.diff_output_cache, data)
      end
    end,
    on_stderr = function(_, data)
      data = table.concat(data, '\n')
      if #data > 1 or (#data == 1 and #data[1] > 0) then
        Diff.git_diff = nil
        Diff.diff_output_cache = {}
      end
    end,
    on_exit = function()
      if #Diff.diff_output_cache > 0 then
        Diff.process_diff(Diff.diff_output_cache)
      else
        Diff.git_diff = {added = 0, modified = 0, removed = 0}
      end
      diff_cache[vim.fn.bufnr()] = Diff.git_diff
    end
  }
  Diff.update_git_diff()
end

-- Update git_diff veriable
function Diff.update_git_diff()
  if Diff.diff_args then
    Diff.diff_output_cache = {}
    if Diff.diff_job then Diff.diff_job:stop() end
    Diff.diff_job = Job(Diff.diff_args)
    if Diff.diff_job then Diff.diff_job:start() end
  end
end

return Diff
