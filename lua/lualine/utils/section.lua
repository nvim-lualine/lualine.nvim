-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = {}
local utils = require('lualine.utils.utils')
-- Returns formated string for a section
function M.draw_section(section, highlight_name)
  local status = {}
  for _, component in pairs(section) do
    -- load components into status table
    table.insert(status, component:draw(highlight_name))
  end

  -- Flags required for knowing when to remove component separator
  local next_component_colored = false
  local last_component_found = false

  -- Check through components to see when component separator need to be removed
  for component_no = #section, 1, -1 do
    -- Remove component separator with highlight for last component
    if not last_component_found and #status[component_no] > 0 then
      last_component_found = true
      status[component_no] = section[component_no]:strip_separator(
                                 highlight_name)
    end
    -- Remove component separator when color option is used in next component
    if next_component_colored then
      next_component_colored = false
      status[component_no] = section[component_no]:strip_separator()
    end
    -- Remove component separator when color option is used to color background
    if (type(section[component_no].options.color) == 'table' and
        section[component_no].options.color.bg) or
        type(section[component_no].options.color)  == 'string' then
      next_component_colored = true
      status[component_no] = section[component_no]:strip_separator()
    end
  end

  -- Remove empty strings from status
  status = utils.list_shrink(status)
  local status_str = table.concat(status)
  if status_str:find('%%#.*#') == 1 or #status_str == 0 then
    -- Don't prepend with old highlight when the component changes it imidiately
    return status_str
  else
    return highlight_name .. status_str
  end
end

return M
