-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local require = require('lualine_require').require
local utils = require('lualine.utils.utils')
local modules = require('lualine_require').lazy_require {
  utils_notices = 'lualine.utils.notices',
}

local config = {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = vim.go.laststatus == 3,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
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
  winbar = {},
  inactive_winbar = {},
  extensions = {},
}

--- change separator format 'x' to {left='x', right='x'}
---@param separators string|table
---@return table
local function fix_separators(separators)
  if separators ~= nil then
    if type(separators) == 'string' then
      return { left = separators, right = separators }
    end
  end
  return separators
end

---copy raw disabled_filetypes to inner statusline & winbar tables.
---@param disabled_filetypes table
---@return table
local function fix_disabled_filetypes(disabled_filetypes)
  if disabled_filetypes == nil then
    return
  end
  if disabled_filetypes.statusline == nil then
    disabled_filetypes.statusline = {}
  end
  if disabled_filetypes.winbar == nil then
    disabled_filetypes.winbar = {}
  end
  for k, disabled_ft in ipairs(disabled_filetypes) do
    table.insert(disabled_filetypes.statusline, disabled_ft)
    table.insert(disabled_filetypes.winbar, disabled_ft)
    disabled_filetypes[k] = nil
  end
  return disabled_filetypes
end
---extends config based on config_table
---@param config_table table
---@return table copy of config
local function apply_configuration(config_table)
  if not config_table then
    return utils.deepcopy(config)
  end
  local function parse_sections(section_group_name)
    if config_table[section_group_name] == nil then
      return
    end
    if not next(config_table[section_group_name]) then
      config[section_group_name] = {}
      return
    end
    for section_name, section in pairs(config_table[section_group_name]) do
      if section_name == 'refresh' then
        config[section_group_name][section_name] =
          vim.tbl_deep_extend('force', config[section_group_name][section_name], utils.deepcopy(section))
      else
        config[section_group_name][section_name] = utils.deepcopy(section)
      end
    end
  end
  if config_table.options and config_table.options.globalstatus and vim.fn.has('nvim-0.7') == 0 then
    modules.utils_notices.add_notice(
      '### Options.globalstatus\nSorry `globalstatus` option can only be used in neovim 0.7 or higher.\n'
    )
    config_table.options.globalstatus = false
  end
  if vim.fn.has('nvim-0.8') == 0 and (next(config_table.winbar or {}) or next(config_table.inactive_winbar or {})) then
    modules.utils_notices.add_notice('### winbar\nSorry `winbar can only be used in neovim 0.8 or higher.\n')
    config_table.winbar = {}
    config_table.inactive_winbar = {}
  end
  parse_sections('options')
  parse_sections('sections')
  parse_sections('inactive_sections')
  parse_sections('tabline')
  parse_sections('winbar')
  parse_sections('inactive_winbar')
  if config_table.extensions then
    config.extensions = utils.deepcopy(config_table.extensions)
  end
  config.options.section_separators = fix_separators(config.options.section_separators)
  config.options.component_separators = fix_separators(config.options.component_separators)
  config.options.disabled_filetypes = fix_disabled_filetypes(config.options.disabled_filetypes)
  return utils.deepcopy(config)
end

--- returns current active config
---@return table a copy of config
local function get_current_config()
  return utils.deepcopy(config)
end

return {
  get_config = get_current_config,
  apply_configuration = apply_configuration,
}
