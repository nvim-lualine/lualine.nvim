-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = {}
local require = require('lualine_require').require
local utils = require('lualine.utils.utils')
local highlight = require('lualine.highlight')

---runs draw function on components in section
---handles separator edge cases :/
---also handles default transitional separators at section boundaries
---(why? I don't know)
---@param section table list of components
---@param section_name string used for getting proper hl
---@param is_focused boolean
---@return string formated string for a section
--TODO Clean this up this does lots of messy stuff.
function M.draw_section(section, section_name, is_focused)
  local highlight_name = highlight.format_highlight(section_name, is_focused)

  local status = {}
  for _, component in pairs(section) do
    -- load components into status table
    if type(component) ~= 'table' or (type(component) == 'table' and not component.component_no) then
      return '' -- unknown element in section. section posibly not yet loaded
    end
    table.insert(status, component:draw(highlight_name, is_focused))
  end

  local section_color = utils.extract_highlight_colors(string.match(highlight_name, '%%#(.*)#'))

  -- Flags required for knowing when to remove component separator
  local strip_next_component = false
  local last_component_found = false
  local first_component_no = #section

  -- Check through components to see when component separator need to be removed
  for component_no = #section, 1, -1 do
    if #status[component_no] > 0 then
      first_component_no = component_no
    end
    -- Remove component separator with highlight for last component
    if not last_component_found and #status[component_no] > 0 then
      last_component_found = true
      status[component_no] = section[component_no]:strip_separator()
      if section_name < 'c' then
        if
          type(section[first_component_no].options.separator) ~= 'table'
          and (section[1].options.section_separators.left ~= nil and section[1].options.section_separators.left ~= '')
        then
          status[component_no] =
            string.format('%s%%S{%s}', status[component_no], section[1].options.section_separators.left)
        end
      end
    end
    -- Remove component separator when color option is used in next component
    if strip_next_component then
      strip_next_component = false
      status[component_no] = section[component_no]:strip_separator()
    end
    -- Remove component separator when color option is used to color background
    if
      (
        type(section[component_no].options.color) == 'table'
        and section[component_no].options.color.bg
        and section[component_no].options.color.bg ~= section_color.bg
      )
      or type(section[component_no].options.color) == 'string'
      or (
        type(section[component_no].options.color) == 'function'
        and section[component_no].color_fn_cache
        and section[component_no].color_fn_cache.bg
        and section[component_no].color_fn_cache.bg ~= section_color.bg
      )
    then
      strip_next_component = true
      status[component_no] = section[component_no]:strip_separator()
    end

    if section[component_no].strip_previous_separator == true then
      strip_next_component = true
    end
  end

  local left_sparator_string = ''
  if
    section_name > 'x'
    and section[first_component_no]
    and type(section[first_component_no].options.separator) ~= 'table'
    and (section[1].options.section_separators.right ~= nil and section[1].options.section_separators.right ~= '')
  then
    left_sparator_string = string.format(
      '%%s{%s}',
      section[first_component_no].options.ls_separator or section[1].options.section_separators.right
    )
  end

  -- Remove empty strings from status
  status = utils.list_shrink(status)
  local status_str = table.concat(status)

  if #status_str == 0 then
    return ''
  end

  local needs_hl

  local find_start_trans_sep_start, find_start_trans_sep_end = status_str:find('^%%s{.-}')
  if find_start_trans_sep_start then
    -- the section doesn't need to be prepended with default hl when sections
    -- first component has trasitionals sep
    needs_hl = status_str:find('^%%#', find_start_trans_sep_end + 1)
  else
    needs_hl = status_str:find('^%%#')
  end

  if needs_hl then
    -- Don't prepend with old highlight when the component changes it imidiately
    return left_sparator_string .. status_str
  else
    return left_sparator_string .. highlight_name .. status_str
  end
end

return M
