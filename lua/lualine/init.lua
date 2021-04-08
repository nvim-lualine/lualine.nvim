-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local utils_section = require('lualine.utils.section')
local highlight = require('lualine.highlight')
local config = require('lualine.defaults')

local function apply_configuration(config_table)
  if not config_table then return end
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

local function load_special_components(component)
  return function()
    -- precedence lualine_component > vim_var > lua_var > vim_function
    if component:find('[gvtwb]?o?:') == 1 then
      -- vim veriable component
      -- accepts g:, v:, t:, w:, b:, o, go:, vo:, to:, wo:, bo:
      -- filters g portion from g:var
      local scope = component:match('[gvtwb]?o?')
      -- filters var portion from g:var
      local var_name = component:sub(#scope + 2, #component)
      -- Displays nothing when veriable aren't present
      local return_val = vim[scope][var_name]
      if return_val == nil then return '' end
      local ok
      ok, return_val = pcall(tostring, return_val)
      if ok then return return_val end
      return ''
    elseif loadstring(string.format('return %s ~= nil', component)) and
        loadstring(string.format([[return %s ~= nil]], component))() then
      -- lua veriable component
      return loadstring(string.format([[
      local ok, return_val = pcall(tostring, %s)
      if ok then return return_val end
      return '']], component))()
    else
      -- vim function component
      local ok, return_val = pcall(vim.fn[component])
      if not ok then return '' end -- function call failed
      ok, return_val = pcall(tostring, return_val)
      if ok then
        return return_val
      else
        return ''
      end
    end
  end
end

local function component_loader(component)
  if type(component[1]) == 'function' then return component end
  if type(component[1]) == 'string' then
    -- Keep component name for later use as component[1] will be overwritten
    -- With component function
    component.component_name = component[1]
    -- apply default args
    for opt_name, opt_val in pairs(config.options) do
      if component[opt_name] == nil then component[opt_name] = opt_val end
    end
    -- load the component
    local ok, loaded_component = pcall(require, 'lualine.components.' ..
                                           component.component_name)
    if not ok then
      loaded_component = load_special_components(component.component_name)
    end
    component[1] = loaded_component
    if type(component[1]) == 'table' then
      component[1] = component[1].init(component)
    end
    -- set custom highlights
    if component.color then
      component.color_highlight = highlight.create_component_highlight_group(
                                      component.color, component.component_name,
                                      component)
    end
  end
end

local function load_sections(sections)
  for section_name, section in pairs(sections) do
    for index, component in pairs(section) do
      if type(component) == 'string' or type(component) == 'function' then
        component = {component}
      end
      component.self = {}
      component.self.section = section_name
      component_loader(component)
      section[index] = component
    end
  end
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
  local theme_config = config.options.theme
  local ok, theme
  if type(theme_config) == 'string' then
    ok, theme = pcall(require, 'lualine.themes.' .. theme_config)
    if not ok then
      vim.api.nvim_echo({
        {
          'theme ' .. theme_config .. ' not found defaulting to gruvbox',
          'ErrorMsg'
        }
      }, true, {})
      theme = require 'lualine.themes.gruvbox'
    end
  elseif type(theme_config) == 'table' then
    theme = theme_config
  else
    vim.api.nvim_echo({
      {
        type(theme_config)..' is not a valid type of theme defaulting to gruvbox',
        'ErrorMsg'
      }
    }, true, {})
    theme = require 'lualine.themes.gruvbox'
  end
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
    _G.lualine_tabline = tabline
    vim.o.tabline = '%!v:lua.lualine_tabline()'
    vim.o.showtabline = 2
  end
end

local function set_statusline()
  if next(config.sections) ~= nil or next(config.inactive_sections) ~= nil then
    _G.lualine_statusline = status_dispatch
    vim.o.statusline = '%!v:lua.lualine_statusline()'
    vim.api.nvim_exec([[
    autocmd lualine WinLeave,BufLeave * lua vim.wo.statusline=lualine_statusline()
    autocmd lualine WinEnter,BufEnter * setlocal statusline=%!v:lua.lualine_statusline()
    ]], false)
  end
end

local function setup(user_config)
  apply_configuration(vim.g.lualine)
  apply_configuration(user_config)
  check_single_separator()
  setup_theme()
  load_components()
  load_extensions()
  set_statusline()
  set_tabline()
end

return {setup = setup}
