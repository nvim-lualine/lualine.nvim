-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local utils_component = require('lualine.utils.component')
local utils = require('lualine.utils.utils')
local highlight = require('lualine.highlight')

local M = { }

local theme_set = {}

M.options = {
  icons_enabled = true,
  theme = 'gruvbox',
	component_separators = {'', ''},
	section_separators = {'', ''},
}


M.sections = {
  lualine_a = { 'mode' },
  lualine_b = { 'branch' },
  lualine_c = { 'filename' },
  lualine_x = { 'encoding', 'fileformat', 'filetype' },
  lualine_y = { 'progress' },
  lualine_z = { 'location'  },
}

M.inactive_sections = {
  lualine_a = {  },
  lualine_b = {  },
  lualine_c = { 'filename' },
  lualine_x = { 'location' },
  lualine_y = {  },
  lualine_z = {  }
}

M.extensions = {
}

local function load_special_components(component)
  return function()
    -- precedence lualine_component > vim_var > lua_var > vim_function
    if component:find('[gvtwb]?o?:') == 1 then
      -- vim veriable component
      -- accepts g:, v:, t:, w:, b:, o, go:, vo:, to:, wo:, bo:
      -- filters g portion from g:var
      local scope = component:match('[gvtwb]?o?')
      -- filters var portion from g:var
      -- For some reason overwriting component var from outer scope causes the
      -- component not to work . So creating a new local name component to use:/
      local component = component:sub(#scope + 2, #component)
      -- Displays nothing when veriable aren't present
      local return_val = vim[scope][component]
      if return_val == nil then return '' end
      local ok
      ok, return_val =  pcall(tostring, return_val)
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
      ok, return_val =  pcall(tostring, return_val)
      if ok then return return_val else return '' end
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
    for opt_name, opt_val in pairs(M.options) do
      if component[opt_name] == nil then
        component[opt_name] = opt_val
      end
    end
    -- load the component
    local ok, loaded_component = pcall(require, 'lualine.components.' .. component.component_name)
    if not ok then
      loaded_component = load_special_components(component.component_name)
    end
    component[1] = loaded_component
    if type(component[1]) == 'table' then
      component[1] = component[1].init(component)
    end
    -- set custom highlights
    if component.color then
      local function update_color()
        component.color_highlight = highlight.create_component_highlight_group(
        component.color, component.component_name, component)
      end
      update_color()
      utils.expand_set_theme(update_color)
    end
  end
end


local function load_components()
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
  load_sections(M.sections)
  load_sections(M.inactive_sections)
end

local function  load_extensions()
  for _, extension in pairs(M.extensions) do
    if type(extension) == 'string' then
      require('lualine.extensions.' .. extension).load_extension()
    end
    if type(extension) == 'table' then
      extension.load_extension()
    end
    if type(extension) == 'function' then
      extension()
    end
  end
end

local function set_lualine_theme()
  if type(M.options.theme) == 'string' then
    M.options.theme = require('lualine.themes.'.. M.options.theme)
  end
  highlight.create_highlight_groups(M.options.theme)
  theme_set = M.options.theme
end

local function statusline(sections, is_focused)
  if M.theme ~= theme_set then
    set_lualine_theme()
  end
  -- status_builder stores statusline without section_separators
  local status_builder = {}
  -- The sequence sections should maintain
  local section_sequence = {'a', 'b', 'c', 'x', 'y', 'z'}

  for _, sec in ipairs(section_sequence) do
    if sections['lualine_'..sec] then
      -- insert highlight+components of this section to status_builder
      local highlight = highlight.format_highlight(is_focused,
                   'lualine_'..sec)
      table.insert(status_builder, {sec, utils_component.draw_section(sections['lualine_'..sec], highlight)})
    end
  end

  -- Actual statusline
  local status = {}
  local half_passed = false
  for i=1,#status_builder do
    -- midsection divider
    if not half_passed and status_builder[i][1] > 'c' then
      table.insert(status, highlight.format_highlight(is_focused, 'lualine_c') .. '%=')
      half_passed = true
    end
    -- provide section_separators when statusline is in focus
    if is_focused then
      -- component separator needs to have fg = current_section.bg
      -- and bg = adjacent_section.bg
      local prev_section = status_builder[i-1] and status_builder[i-1] or {[2] = nil}
      local cur_section = status_builder[i]
      local next_section = status_builder[i+1] and status_builder[i+1] or {[2] = nil}
      -- For 2nd half we need to show separator before section
      if cur_section[1] > 'x' then
        local hl = highlight.get_transitional_highlights(prev_section[2], cur_section[2], true)
        if hl then table.insert(status, hl .. M.options.section_separators[2]) end
      end

      -- **( insert the actual section in the middle )** --
      table.insert(status, status_builder[i][2])

      -- For 1st half we need to show separator after section
      if cur_section[1] < 'c' then
        local hl = highlight.get_transitional_highlights(cur_section[2], next_section[2])
        if hl then table.insert(status, hl .. M.options.section_separators[1]) end
      end
    else -- when not in focus
      table.insert(status, status_builder[i][2])
    end
  end
  -- incase none of x,y,z was configured lets not fill whole statusline with a,b,c section
  if not half_passed then
    table.insert(status, highlight.format_highlight(is_focused,'lualine_c').."%=") end
  return table.concat(status)
end

local function status_dispatch()
  if vim.g.statusline_winid == vim.fn.win_getid() then
    return statusline(M.sections, true)
  else
    return statusline(M.inactive_sections, false)
  end
end

local function exec_autocommands()
  _G.set_lualine_theme = set_lualine_theme
  vim.api.nvim_exec([[
    augroup lualine
    autocmd!
    autocmd ColorScheme * call v:lua.set_lualine_theme()
    augroup END
  ]], false)
end

function M.status()
  set_lualine_theme()
  exec_autocommands()
  load_components()
  load_extensions()
  _G.lualine_statusline = status_dispatch
  vim.o.statusline = '%!v:lua.lualine_statusline()'
end

return M
