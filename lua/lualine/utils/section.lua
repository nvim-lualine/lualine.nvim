-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local utils_component = require('lualine.utils.component')
local M = {}
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
      localstatus = utils_component.apply_icon(localstatus, component)
      localstatus = utils_component.apply_case(localstatus, component)
      localstatus = utils_component.apply_padding(localstatus, component)
      localstatus = utils_component.apply_highlights(localstatus, component,
                                                     highlight_name)
      localstatus = utils_component.apply_spearator(localstatus, component)
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
      status[i] =
          utils_component.strip_separator(status[i], drawn_components[i])
      if i > 1 then
        status[i - 1] = utils_component.strip_separator(status[i - 1],
                                                        drawn_components[i - 1])
      end
    end
  end
  status[#status] = utils_component.strip_separator(status[#status],
                                                    drawn_components[#status])
  return table.concat(status)
end

return M
