-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local async = require'lualine.async'
local utils = require'lualine.utils.utils'
local highlight = require"lualine.highlight"

-- variable to store git diff stats
local git_diff = nil
-- accumulates async output to process in the end
local diff_data = ''

-- process diff data and update git_diff{ added, removed, modified}
local function process_diff(data)
  -- Adapted from https://github.com/wbthomason/nvim-vcs.lua
  local added, removed, modified = 0, 0, 0
  for line in vim.gsplit(data, '\n') do
    if string.find(line, [[^@@ ]]) then
      local tokens = vim.fn.matchlist(line, [[^@@ -\v(\d+),?(\d*) \+(\d+),?(\d*)]])
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
        added  = added + line_stats.new_count - min
        removed = removed + line_stats.mod_count - min
      end
    end
  end
  git_diff = { added,  modified, removed }
end

-- variable to store git_diff getter async function
local get_git_diff = nil

-- Updates the async function for current file
local function update_git_diff_getter()
  -- stop older function properly before overwritting it
  if get_git_diff then get_git_diff:stop() end
  -- Donn't show git diff when current buffer doesn't have a filename
  if #vim.fn.expand('%') == 0 then get_git_diff = nil; git_diff=nil; return end
  get_git_diff = async:new({
    cmd = string.format([[git -C %s --no-pager diff --no-color --no-ext-diff -U0 -- %s]]
    ,vim.fn.expand('%:h'), vim.fn.expand('%:t')),
    on_stdout = function(_, data)
      if data then
        diff_data = diff_data .. data
      end
    end,
    on_stderr = function (_, data)
      if data then
        git_diff = nil
        diff_data = ''
      end
    end,
    on_exit = function()
      if diff_data ~= ''  then
        process_diff(diff_data)
      else
        git_diff = {0, 0, 0}
      end
    end
  })
end

-- Update git_diff veriable
local function update_git_diff()
  vim.schedule_wrap(function()
    if get_git_diff then
      diff_data = ''
      get_git_diff:start()
    end
  end)()
end

local default_color_added    = "#f0e130"
local default_color_removed  = "#90ee90"
local default_color_modified = "#ff0038"

local function diff(options)
  if options.colored == nil then options.colored = true end
  -- apply colors
  if not options.color_added then
    options.color_added = utils.extract_highlight_colors('DiffAdd', 'guifg') or default_color_added
  end
  if not options.color_modified then
    options.color_modified = utils.extract_highlight_colors('DiffChange', 'guifg') or default_color_modified
  end
  if not options.color_removed then
    options.color_removed = utils.extract_highlight_colors('DiffDelete', 'guifg') or default_color_removed
  end

  local highlights = {}

  -- create highlights and save highlight_name in highlights table
  local function create_highlights()
    highlights = {
      highlight.create_component_highlight_group({fg = options.color_added}, 'diff_added', options),
      highlight.create_component_highlight_group({fg = options.color_modified}, 'diff_modified', options),
      highlight.create_component_highlight_group({fg = options.color_removed}, 'diff_removed', options),
    }
  end

  vim.api.nvim_exec([[
    autocmd lualine BufEnter     * lua require'lualine.components.diff'.update_git_diff_getter()
    autocmd lualine BufEnter     * lua require'lualine.components.diff'.update_git_diff()
    autocmd lualine BufWritePost * lua require'lualine.components.diff'.update_git_diff()
    ]], false)

  -- create highlights
  if options.colored then
    create_highlights()
    utils.expand_set_theme(create_highlights)
  end

  -- Function that runs everytime statusline is updated
  return function()
    if git_diff == nil then return '' end

    local symbols = {'+', '~', '-'}
    local colors = {}
    if options.colored then
      -- load the highlights and store them in colors table
      for _, highlight_name in ipairs(highlights) do
        table.insert(colors, highlight.component_format_highlight(highlight_name))
      end
    end

    local result = {}
    -- loop though data and load available sections in result table
    for range=1,3 do
      if git_diff[range] ~= nil and git_diff[range] > 0 then
        if options.colored then
          table.insert(result,colors[range]..symbols[range]..git_diff[range])
        else
          table.insert(result,symbols[range]..git_diff[range])
        end
      end
    end
    if result[1] ~= nil then
      return table.concat(result, ' ')
    else
      return ''
    end
  end
end

-- Api to get git sign count
-- scheme :
-- {
--    added = added_count,
--    modified = modified_count,
--    removed = removed_count,
-- }
-- error_code = { -1, -1, -1 }
local function get_sign_count()
  update_git_diff_getter()
  update_git_diff()
  if git_diff then
    return{
      added = git_diff[1],
      modified = git_diff[2],
      removed = git_diff[3]
    }
  end
  return {-1, -1, -1}
end

return {
  init = function(options) return diff(options) end,
  update_git_diff = update_git_diff,
  update_git_diff_getter = update_git_diff_getter,
  get_sign_count = get_sign_count,
}
