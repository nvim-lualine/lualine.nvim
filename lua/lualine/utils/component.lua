-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local M = {  }

local highlight = require'lualine.highlight'

-- set upper or lower case
local function apply_case(status, options)
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
local function apply_padding(status, options)
  local l_padding = (options.left_padding  or options.padding or 1)
  local r_padding = (options.right_padding or options.padding or 1)
  if l_padding then status = string.rep(' ', l_padding)..status end
  if r_padding then status = status..string.rep(' ', r_padding) end
  return status
end

-- Applies custom highlights for component
local function apply_highlights(status, options)
  if options.color_highlight then
    status = highlight.component_format_highlight(options.color_highlight) .. status
  end
  return status
end

-- Apply icon in front of component
local function apply_icon(status, options)
  if options.icons_enabled and options.icon then
    status = options.icon .. ' ' .. status
  end
  return status
end

-- Apply separator at end of component only when
-- custom highlights haven't affected background
local function apply_spearator(status, options)
  if options.separator and #options.separator > 0 and
     (not options.color or not options.color.bg) then
    status = status .. options.separator
    options.separator_applied = true
  end
  return status
end

-- Returns formated string for a section
function M.draw_section(section, highlight)
  local status = {}
  for _, component in pairs(section) do
    -- Reset flags
    component.drawn = false -- Flag to check if a component was drawn or not
    component.separator_applied = false -- Flag to check if separator was applied
    local localstatus = component[1]()
    if #localstatus > 0 then
      -- Apply modifier functions for options
      if component.format then localstatus = component.format(localstatus) end
      localstatus = apply_icon(localstatus, component)
      localstatus = apply_case(localstatus, component)
      localstatus = apply_padding(localstatus, component)
      localstatus = apply_highlights(localstatus, component)
      localstatus = apply_spearator(localstatus, component)
      table.insert(status, localstatus)
      component.drawn = true
    end
  end
  -- Draw nothing when all the components were empty
  if #status == 0 then return '' end
  -- convert to single string
  -- highlight is used as separator so custom highlights don't affect
  -- later components
  local status_str = highlight .. table.concat(status, highlight)
  -- Remove separator from last drawn component if available
  for last_component = #section, 1, -1 do
    if section[last_component].drawn then
      if section[last_component].separator_applied then
        status_str = status_str:sub(1, #status_str - #section[last_component].separator)
      end
      break
    end
  end
  return status_str
end


return M
