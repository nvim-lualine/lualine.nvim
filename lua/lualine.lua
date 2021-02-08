local utils = require('lualine.utils')
local highlight = require('lualine.highlight')

local M = { }

M.theme = 'gruvbox'
local theme_set = {}

M.separator = '|'

M.opt = {
  icons_enabled = true,
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

local function component_loader(component)
  if type(component[1]) == 'function' then return component end
  -- apply default args
  for opt_name, opt_val in pairs(M.opt) do
    if component[opt_name] == nil then
      component[opt_name] = opt_val
    end
  end
  -- set custom highlights
  if component.color then
    local component_name = component[1]
    local color = component.color
    local function update_color()
      component.color = highlight.create_component_highlight_group(color, component_name, component)
    end
    update_color()
    utils.expand_set_theme(update_color)
  end
  -- load the component
  component[1] = require('lualine.components.' .. component[1])
  if type(component[1]) == 'table' then
    component[1] = component[1].init(component)
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
        -- used to provide default for bg and fg for custom highlights
        component.self.theme = theme_set
        -- setting highlight because utils need highlight but cann't require
        -- it as it creates circular dependency . It's a workaround for now
        -- Should look for a better solution.
        component.self.highlight = highlight
        -- convert lualine_section -> section before setting section
        component.self.section = section_name:sub(9,10)
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
  if type(M.theme) == 'string' then
    M.theme = require('lualine.themes.'.. M.theme)
  end
  highlight.create_highlight_groups(M.theme)
  theme_set = M.theme
end

local function statusline(sections, is_focused)
  local status = {}
  if sections.lualine_a then
    local hl = highlight.format_highlight(is_focused, 'lualine_a')
    table.insert(status, utils.draw_section(sections.lualine_a, M.separator, hl))
  end
  if sections.lualine_b then
    local hl = highlight.format_highlight(is_focused, 'lualine_b')
    table.insert(status, utils.draw_section(sections.lualine_b, M.separator, hl))
  end
  if sections.lualine_c then
    local hl = highlight.format_highlight(is_focused, 'lualine_c')
    table.insert(status, utils.draw_section(sections.lualine_c, M.separator, hl))
  end
  table.insert(status, "%=")
  if sections.lualine_x then
    local hl = highlight.format_highlight(is_focused, 'lualine_c')
    table.insert(status, utils.draw_section(sections.lualine_x, M.separator, hl))
  end
  if sections.lualine_y then
    local hl = highlight.format_highlight(is_focused, 'lualine_b')
    table.insert(status, utils.draw_section(sections.lualine_y, M.separator, hl))
  end
  if sections.lualine_z then
    local hl = highlight.format_highlight(is_focused, 'lualine_a')
    table.insert(status, utils.draw_section(sections.lualine_z, M.separator, hl))
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
