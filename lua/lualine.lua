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
  separator = '|',
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

M.tabline = {}

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
  load_sections(M.tabline)
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
  local status = {}
  if sections.lualine_a then
    local hl = highlight.format_highlight(is_focused, 'lualine_a')
    table.insert(status, utils_component.draw_section(sections.lualine_a,  hl))
  end
  if sections.lualine_b then
    local hl = highlight.format_highlight(is_focused, 'lualine_b')
    table.insert(status, utils_component.draw_section(sections.lualine_b,  hl))
  end
  if sections.lualine_c then
    local hl = highlight.format_highlight(is_focused, 'lualine_c')
    table.insert(status, utils_component.draw_section(sections.lualine_c,  hl))
  end
  table.insert(status, "%=")
  if sections.lualine_x then
    local hl = highlight.format_highlight(is_focused, 'lualine_c')
    table.insert(status, utils_component.draw_section(sections.lualine_x,  hl))
  end
  if sections.lualine_y then
    local hl = highlight.format_highlight(is_focused, 'lualine_b')
    table.insert(status, utils_component.draw_section(sections.lualine_y,  hl))
  end
  if sections.lualine_z then
    local hl = highlight.format_highlight(is_focused, 'lualine_a')
    table.insert(status, utils_component.draw_section(sections.lualine_z,  hl))
  end
  return table.concat(status)
end

local function status_dispatch()
  if vim.g.statusline_winid == vim.fn.win_getid() then
    return statusline(M.sections, true)
  else
    return statusline(M.inactive_sections, false)
  end
end

local function tabline()
  return statusline(M.tabline, true)
end

local function exec_autocommands()
  _G.set_lualine_theme = set_lualine_theme
  _G.lualine_statusline = status_dispatch
  vim.api.nvim_exec([[
    augroup lualine
    autocmd!
    autocmd ColorScheme * call v:lua.set_lualine_theme()
    autocmd WinLeave,BufLeave * lua vim.wo.statusline=lualine_statusline()
    autocmd WinEnter,BufEnter * setlocal statusline=%!v:lua.lualine_statusline()
    augroup END
  ]], false)
end

function M.status()
  set_lualine_theme()
  exec_autocommands()
  load_components()
  load_extensions()
  if next(M.tabline) ~= nil then
    _G.lualine_tabline = tabline
    vim.o.tabline = '%!v:lua.lualine_tabline()'
    vim.o.showtabline = 2
  end
end

return M
