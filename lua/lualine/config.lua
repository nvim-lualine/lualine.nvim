-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local config = {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', { 'diagnostics', sources = { 'nvim_lsp', 'coc' } } },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
}

local function check_sep_format_deprication(sep)
  if type(sep) == 'table' and vim.tbl_islist(sep) then
    require('lualine.utils.notices').add_persistent_notice(string.format [[
### option.separator
Using list for configuring separators has been depricated. Please configure it
with {left = left_sep, right = right_sep} like table.
]])
    sep = { left = sep[1], right = sep[2] or sep[1] }
  end
  return sep
end

-- change separator format 'x' to {left='x', right='x'}
local function fix_separators(separators)
  if separators ~= nil then
    if type(separators) == 'string' then
      return { left = separators, right = separators }
    else
      return check_sep_format_deprication(separators)
    end
  end
  return separators
end

local function apply_configuration(config_table)
  if not config_table then
    return vim.deepcopy(config)
  end
  local function parse_sections(section_group_name)
    if not config_table[section_group_name] then
      return
    end
    for section_name, section in pairs(config_table[section_group_name]) do
      config[section_group_name][section_name] = vim.deepcopy(section)
    end
  end
  parse_sections 'options'
  parse_sections 'sections'
  parse_sections 'inactive_sections'
  parse_sections 'tabline'
  if config_table.extensions then
    config.extensions = vim.deepcopy(config_table.extensions)
  end
  config.options.section_separators = fix_separators(config.options.section_separators)
  config.options.component_separators = fix_separators(config.options.component_separators)
  return vim.deepcopy(config)
end

local function get_current_config()
  return vim.deepcopy(config)
end

return {
  get_config = get_current_config,
  apply_configuration = apply_configuration,
}
