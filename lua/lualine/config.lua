-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local config = {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    component_separators = {'', ''},
    section_separators = {'', ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

-- change separator format 'x' or {'x'} to {'x', 'x'}
local function fix_separators(separators)
  if separators ~= nil then
    if type(separators) == 'string' then
      return {separators, separators}
    elseif type(separators) == 'table' and #separators == 1 then
      return {separators[1], separators[1]}
    end
  end
  return separators
end

local function apply_configuration(config_table)
  local function parse_sections(section_group_name)
    if not config_table[section_group_name] then return end
    for section_name, section in pairs(config_table[section_group_name]) do
      config[section_group_name][section_name] =
          config_table[section_group_name][section_name]
      if type(section) == 'table' then
        for _, component in pairs(section) do
          if type(component) == 'table' and type(component[2]) == 'table' then
            local options = component[2]
            component[2] = nil
            for key, val in pairs(options) do component[key] = val end
          end
        end
      end
    end
  end
  parse_sections('options')
  parse_sections('sections')
  parse_sections('inactive_sections')
  parse_sections('tabline')
  if config_table.extensions then config.extensions = config_table.extensions end
  config.options.section_separators = fix_separators(
                                          config.options.section_separators)
  config.options.component_separators = fix_separators(
                                            config.options.component_separators)
end

return {config = config, apply_configuration = apply_configuration}
