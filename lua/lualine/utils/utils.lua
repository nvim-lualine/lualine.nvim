-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = {}

-- Note for now only works for termguicolors scope can be bg or fg or any other
-- attr parameter like bold/italic/reverse
function M.extract_highlight_colors(color_group, scope)
  if vim.fn.hlexists(color_group) == 0 then return nil end
  local color = vim.api.nvim_get_hl_by_name(color_group, true)
  if color.background ~= nil then
    color.bg = string.format('#%06x', color.background)
    color.background = nil
  end
  if color.foreground ~= nil then
    color.fg = string.format('#%06x', color.foreground)
    color.foreground = nil
  end
  if scope then return color[scope] end
  return color
end

-- table to store the highlight names created by lualine
M.loaded_highlights = {}

-- sets loaded_highlights table
function M.save_highlight(highlight_name, highlight_args)
  M.loaded_highlights[highlight_name] = highlight_args
end

function M.reload_highlights()
  local highlight = require('lualine.highlight')
  for _, highlight_args in pairs(M.loaded_highlights) do
    highlight.highlight(unpack(highlight_args))
  end
end

-- determine if an highlight exist and isn't cleared
function M.highlight_exists(highlight_name)
  return M.loaded_highlights[highlight_name] and true or false
end

-- clears loaded_highlights table and highlights
function M.clear_highlights()
  for highlight_name, _ in pairs(M.loaded_highlights) do
    vim.cmd('highlight clear ' .. highlight_name)
    M.loaded_highlights[highlight_name] = nil
  end
end

-- remove empty strings from list
function M.list_shrink(list)
  local new_list = {}
  for i = 1, #list do
    if list[i] and #list[i] > 0 then table.insert(new_list, list[i]) end
  end
  return new_list
end

return M
