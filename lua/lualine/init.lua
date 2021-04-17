-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local config = require('lualine.defaults')
local highlight = require('lualine.highlight')
local loader = require('lualine.utils.loader')
local utils_section = require('lualine.utils.section')

-- change separator format 'x' or {'x'} to {'x', 'x'}
local function fix_separators(separators)
  if separators ~= nil then
    if type(separators) == 'string' then
      return {separators, separators}
    elseif #separators == 1 then
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

local function statusline(sections, is_focused)
  local function create_status_builder()
    -- The sequence sections should maintain
    local section_sequence = {'a', 'b', 'c', 'x', 'y', 'z'}
    local status_builder = {}
    for _, section_name in ipairs(section_sequence) do
      if sections['lualine_' .. section_name] then
        -- insert highlight+components of this section to status_builder
        local section_highlight = highlight.format_highlight(is_focused,
                                                             'lualine_' ..
                                                                 section_name)
        local section_data = utils_section.draw_section(
                                 sections['lualine_' .. section_name],
                                 section_highlight)
        if #section_data > 0 then
          table.insert(status_builder,
                       {name = section_name, data = section_data})
        end
      end
    end
    return status_builder
  end
  -- status_builder stores statusline without section_separators
  local status_builder = create_status_builder()

  -- Actual statusline
  local status = {}
  local half_passed = false
  for i = 1, #status_builder do
    -- midsection divider
    if not half_passed and status_builder[i].name > 'c' then
      table.insert(status,
                   highlight.format_highlight(is_focused, 'lualine_c') .. '%=')
      half_passed = true
    end
    -- provide section_separators when statusline is in focus
    if is_focused then
      -- component separator needs to have fg = current_section.bg
      -- and bg = adjacent_section.bg
      local previous_section = status_builder[i - 1] or {}
      local current_section = status_builder[i]
      local next_section = status_builder[i + 1] or {}
      -- For 2nd half we need to show separator before section
      if current_section.name > 'x' then
        local transitional_highlight = highlight.get_transitional_highlights(
                                           previous_section.data,
                                           current_section.data, true)
        if transitional_highlight and config.options.section_separators and
            config.options.section_separators[2] then
          table.insert(status, transitional_highlight ..
                           config.options.section_separators[2])
        end
      end

      -- **( insert the actual section in the middle )** --
      table.insert(status, status_builder[i].data)

      -- For 1st half we need to show separator after section
      if current_section.name < 'c' then
        local transitional_highlight = highlight.get_transitional_highlights(
                                           current_section.data,
                                           next_section.data)
        if transitional_highlight and config.options.section_separators and
            config.options.section_separators[1] then
          table.insert(status, transitional_highlight ..
                           config.options.section_separators[1])
        end
      end
    else -- when not in focus
      table.insert(status, status_builder[i].data)
    end
  end
  -- incase none of x,y,z was configured lets not fill whole statusline with a,b,c section
  if not half_passed then
    table.insert(status,
                 highlight.format_highlight(is_focused, 'lualine_c') .. '%=')
  end
  return table.concat(status)
end

-- check if any extension matches the filetype and return proper sections
local function get_extension_sections()
  local sections, inactive_sections = nil, nil
  for _, extension in ipairs(config.extensions) do
    for _, filetype in ipairs(extension.filetypes) do
      if vim.bo.filetype == filetype then
        sections = extension.sections
        inactive_sections = extension.inactive_sections
        break
      end
    end
  end
  return {sections = sections, inactive_sections = inactive_sections}
end

local function status_dispatch()
  local extension_sections = get_extension_sections()
  if vim.g.statusline_winid == vim.fn.win_getid() then
    local sections = extension_sections.sections
    if sections == nil then sections = config.sections end
    return statusline(sections, true)
  else
    local inactive_sections = extension_sections.inactive_sections
    if inactive_sections == nil then
      inactive_sections = config.inactive_sections
    end
    return statusline(inactive_sections, false)
  end
end

local function tabline() return statusline(config.tabline, true) end

local function setup_theme()
  local function get_theme_from_config()
    local theme_name = config.options.theme
    if type(theme_name) == 'string' then
      local ok, theme = pcall(require, 'lualine.themes.' .. theme_name)
      if ok then return theme end
    elseif type(theme_name) == 'table' then
      -- use the provided theme as-is
      return config.options.theme
    end
    vim.api.nvim_echo({
      {
        'theme ' .. tostring(theme_name) .. ' not found, defaulting to gruvbox',
        'ErrorMsg'
      }
    }, true, {})
    return require 'lualine.themes.gruvbox'
  end
  local theme = get_theme_from_config()
  highlight.create_highlight_groups(theme)
  vim.api.nvim_exec([[
  augroup lualine
  autocmd!
  autocmd ColorScheme * lua require'lualine.utils.utils'.reload_highlights()
  augroup END
  ]], false)
end

local function set_tabline()
  if next(config.tabline) ~= nil then
    vim.o.tabline = '%!v:lua.require\'lualine\'.tabline()'
    vim.o.showtabline = 2
  end
end

local function set_statusline()
  if next(config.sections) ~= nil or next(config.inactive_sections) ~= nil then
    vim.o.statusline = '%!v:lua.require\'lualine\'.statusline()'
    vim.api.nvim_exec([[
    autocmd lualine WinLeave,BufLeave * lua vim.wo.statusline=require'lualine'.statusline()
    autocmd lualine WinEnter,BufEnter * set statusline<
    ]], false)
  end
end

local function setup(user_config)
  if user_config then
    apply_configuration(user_config)
  elseif vim.g.lualine then
    apply_configuration(vim.g.lualine)
  end
  setup_theme()
  loader.load_components(config)
  loader.load_extensions(config)
  set_statusline()
  set_tabline()
end

return {setup = setup, statusline = status_dispatch, tabline = tabline}
