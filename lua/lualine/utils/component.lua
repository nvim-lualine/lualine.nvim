-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = {}

local highlight = require 'lualine.highlight'

-- set upper or lower case
function M.apply_case(status, options)
  -- Donn't work on components that emit vim statusline escaped chars
  if status:find('%%') and not status:find('%%%%') then return status end
  if options.upper == true then
    return status:upper()
  elseif options.lower == true then
    return status:lower()
  end
  return status
end

-- Adds spaces to left and right of a component
function M.apply_padding(status, options)
  local l_padding = (options.left_padding or options.padding or 1)
  local r_padding = (options.right_padding or options.padding or 1)
  if l_padding then
    if status:find('%%#.*#') == 1 then
      -- When component has changed the highlight at begining
      -- we will add the padding after the highlight
      local pre_highlight = vim.fn.matchlist(status, [[\(%#.\{-\}#\)]])[2]
      status = pre_highlight .. string.rep(' ', l_padding) ..
                   status:sub(#pre_highlight + 1, #status)
    else
      status = string.rep(' ', l_padding) .. status
    end
  end
  if r_padding then status = status .. string.rep(' ', r_padding) end
  return status
end

-- Applies custom highlights for component
function M.apply_highlights(status, options, default_hl)
  if options.color_highlight then
    status = highlight.component_format_highlight(options.color_highlight) ..
                 status
  end
  return status .. default_hl
end

-- Apply icon in front of component
function M.apply_icon(status, options)
  if options.icons_enabled and options.icon then
    status = options.icon .. ' ' .. status
  end
  return status
end

-- Apply separator at end of component only when
-- custom highlights haven't affected background
function M.apply_spearator(status, options)
  local separator
  if options.separator and #options.separator > 0 then
    separator = options.separator
  elseif options.component_separators then
    if options.self.section < 'lualine_x' then
      separator = options.component_separators[1]
    else
      separator = options.component_separators[2]
    end
    options.separator = separator
  end
  if separator then status = status .. separator end
  options.separator_applied = separator
  return status
end

function M.strip_separator(status, options)
  if options.separator_applied then
    status = status:sub(1, #status - #options.separator_applied)
    options.separator_applied = nil
  end
  return status
end

return M
