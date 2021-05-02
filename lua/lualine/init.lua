-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local utils_section = require('lualine.utils.section')
local highlight = require('lualine.highlight')
local config = {}

local function apply_configuration(config_table)
  local function parse_sections(section_group_name)
    if section_group_name ~= 'options' then
      config[section_group_name] = {} -- clear old config
    else
      -- reset options
      config.options = vim.deepcopy(require'lualine.defaults'.options)
    end
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
  config.extensions = config_table.extensions or {}
end

local function check_single_separator()
  local compoennt_separator = config.options.component_separators
  local section_separator = config.options.section_separators
  if config.options.component_separators ~= nil then
    if type(config.options.component_separators) == 'string' then
      config.options.component_separators =
          {compoennt_separator, compoennt_separator}
    elseif #config.options.component_separators == 1 then
      config.options.component_separators =
          {
            config.options.component_separators[1],
            config.options.component_separators[1]
          }
    end
  end
  if config.options.section_separators ~= nil then
    if type(config.options.section_separators) == 'string' then
      config.options.section_separators = {section_separator, section_separator}
    elseif #config.options.section_separators == 1 then
      config.options.section_separators =
          {
            config.options.section_separators[1],
            config.options.section_separators[1]
          }
    end
  end
end

local function component_loader(component)
  if type(component[1]) == 'function' then
    return require 'lualine.components.special.function_component':new(component)
  end
  if type(component[1]) == 'string' then
    -- load the component
    local ok, loaded_component = pcall(require,
                                       'lualine.components.' .. component[1])
    if ok then
      component.component_name = component[1]
      loaded_component = loaded_component:new(component)
    elseif component[1]:find('[gvtwb]?o?:') == 1 then
      loaded_component =
          require 'lualine.components.special.vim_var_component':new(component)
    else
      loaded_component =
          require 'lualine.components.special.eval_func_component':new(component)
    end
    return loaded_component
  end
end

local function load_sections(sections)
  local async_loader
  async_loader = vim.loop.new_async(vim.schedule_wrap(function()
    for section_name, section in pairs(sections) do
      for index, component in pairs(section) do
        if type(component) == 'string' or type(component) == 'function' then
          component = {component}
        end
        component.self = {}
        component.self.section = section_name
        -- apply default args
        component = vim.tbl_extend('keep', component, config.options)
        section[index] = component_loader(component)
      end
    end
    async_loader:close()
  end))
  async_loader:send()
end

local function load_components()
  load_sections(config.sections)
  load_sections(config.inactive_sections)
  load_sections(config.tabline)
end

local function load_extensions()
  for index, extension in pairs(config.extensions) do
    local local_extension = require('lualine.extensions.' .. extension)
    load_sections(local_extension.sections)
    load_sections(local_extension.inactive_sections)
    config.extensions[index] = local_extension
  end
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
      if current_section.name > 'x' and config.options.section_separators[2] ~= '' then
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
      if current_section.name < 'c' and config.options.section_separators[1] ~= ''  then
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
  local async_loader
  async_loader = vim.loop.new_async(vim.schedule_wrap(function()
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
    async_loader:close()
  end))
  async_loader:send()
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
  augroup lualine
    autocmd WinLeave,BufLeave * lua vim.wo.statusline=require'lualine'.statusline()
    autocmd WinEnter,BufEnter * set statusline<
  augroup END
    ]], false)
  end
end

local function setup(user_config)
  if user_config then
    apply_configuration(user_config)
  elseif vim.g.lualine then
    apply_configuration(vim.g.lualine)
  else
    config =  vim.deepcopy(require('lualine.defaults'))
  end
  check_single_separator()
  setup_theme()
  load_components()
  load_extensions()
  set_statusline()
  set_tabline()
end

return {setup = setup, statusline = status_dispatch, tabline = tabline}
