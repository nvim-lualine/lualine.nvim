-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local utils = require'lualine.utils.utils'

local default_color_added    = "#f0e130"
local default_color_removed  = "#90ee90"
local default_color_modified = "#ff0038"

local function get_highlight(scope, color_group)
  local color = string.format('#%06x', vim.api.nvim_get_hl_by_name(color_group, true)[scope])
  return color or nil
end

local function signify(options)
  if options.colored == nil then options.colored = true end
  local color_added, color_modified, color_removed
  -- apply colors
  if options.color_added then
    color_added = options.color_added
  else
    color_added = get_highlight('foreground', 'diffAdded') or default_color_added
  end
  if options.color_modified then
    color_modified = options.color_modified
  else
    color_modified = get_highlight('foreground', 'diffChanged') or default_color_modified
  end
  if options.color_removed then
    color_removed  = options.color_removed
  else
    color_removed = get_highlight('foreground', 'diffRemoved') or default_color_removed
  end

  local hl = require"lualine.highlight"
  local highlights = {}

  -- create highlights and save highlight_name in highlights table
  local function create_highlights()
    highlights = {
      hl.create_component_highlight_group({fg = color_added}, 'signify_added', options),
      hl.create_component_highlight_group({fg = color_modified}, 'signify_modified', options),
      hl.create_component_highlight_group({fg = color_removed}, 'signify_removed', options),
    }
  end

  -- create highlights
  if options.colored then
    create_highlights()
    utils.expand_set_theme(create_highlights)
    options.custom_highlight = true
  end

  -- Function that runs everytime statusline is updated
  return function()
    -- check if signify is available
    if vim.fn.exists('*sy#repo#get_stats') == 0 then return '' end
    local data = vim.fn['sy#repo#get_stats']()
    if data[1] == -1 then return '' end

    local symbols = {'+', '~', '-'}
    local colors = {}
    if options.colored then
      -- load the highlights and store them in colors table
      for _, highlight_name in ipairs(highlights) do
        table.insert(colors, hl.component_format_highlight(highlight_name))
      end
    end

    local result = {}
    -- loop though data and load available sections in result table
    for range=1,3 do
      if data[range] ~= nil and data[range] > 0 then
        if options.colored then
          table.insert(result,colors[range]..symbols[range]..data[range])
        else
          table.insert(result,symbols[range]..data[range])
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

return { init = function(options) return signify(options) end }
