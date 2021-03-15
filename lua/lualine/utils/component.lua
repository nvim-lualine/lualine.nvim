-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = {}

local highlight = require 'lualine.highlight'

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
local function apply_highlights(status, options, default_hl)
  if options.color_highlight then
    status = highlight.component_format_highlight(options.color_highlight) ..
                 status
  end
  return status .. default_hl
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

local function strip_separator(status, options)
  if options.separator_applied then
    status = status:sub(1, #status - #options.separator_applied)
    options.separator_applied = nil
  end
  return status
end

-- Returns formated string for a section
function M.draw_section(section, highlight_name)
  local status = {}
  local drawn_components = {}
  for _, component in pairs(section) do
    local localstatus = component[1]()
    if #localstatus > 0 then
      local custom_highlight_at_begining =
          localstatus:find('%%#.*#') == 1 or component.color ~= nil
      -- Apply modifier functions for options
      if component.format then localstatus = component.format(localstatus) end
      localstatus = apply_icon(localstatus, component)
      localstatus = apply_case(localstatus, component)
      localstatus = apply_padding(localstatus, component)
      localstatus = apply_highlights(localstatus, component, highlight_name)
      localstatus = apply_spearator(localstatus, component)
      if custom_highlight_at_begining or (#drawn_components > 0 and
          not drawn_components[#drawn_components].separator_applied) then
        -- Don't prepend with old highlight when the component changes it imidiately
        -- Or when it was already applied with separator
        table.insert(status, localstatus)
      else
        table.insert(status, highlight_name .. localstatus)
      end
      table.insert(drawn_components, component)
    end
  end
  -- Draw nothing when all the components were empty
  if #status == 0 then return '' end
  -- Remove separators sorounding custom highlighted component
  for i = 1, #status do
    if (drawn_components[i].color and drawn_components[i].color.bg) or
        drawn_components[i].custom_highlight then
      status[i] = strip_separator(status[i], drawn_components[i])
      if i > 1 then
        status[i - 1] = strip_separator(status[i - 1], drawn_components[i - 1])
      end
    end
  end
  status[#status] = strip_separator(status[#status], drawn_components[#status])
  return table.concat(status)
end

return M
