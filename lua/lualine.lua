local utils = require('lualine.utils')
local highlight = require('lualine.highlight')

local M = { }

M.theme = 'gruvbox'
local theme_set = {}

M.separator = '|'

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
      local component = component:sub(#scope + 2, #component)
      -- Displays nothing when veriablea aren't present
      local ok, value = pcall(function() return vim[scope][component] end)
      if not ok then return '' end
      local return_val
      ok, return_val =  pcall(tostring, value)
      if ok then return return_val end
      return ''
    elseif loadstring(string.format('return %s ~= nil', component)) and
       loadstring(string.format([[return %s ~= nil]], component))() then
      -- lua veriable component
      return loadstring(string.format([[
        local ok, rt_val = pcall(tostring, %s)
        if ok then return rt_val end
        return '']], component))()
    else
      -- vim function component
      local ok, return_val = pcall(vim.fn[component])
      if not ok then return '' end -- function call failed
      local return_str
      ok, return_str =  pcall(tostring, return_val)
      if ok then return return_str else return '' end
    end
  end
end

local function load_components()
  local function load_sections(sections)
    for _, section in pairs(sections) do
      for index, component in pairs(section) do
        if type(component) == 'string' then
          local ok,loaded_component = pcall(require, 'lualine.components.' .. component)
          if not ok then
            loaded_component = load_special_components(component)
          end
          section[index] = loaded_component
        end
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
    table.insert(status, highlight.format_highlight(is_focused, 'lualine_a'))
    table.insert(status, utils.draw_section(sections.lualine_a, M.separator))
  end
  if sections.lualine_b then
    table.insert(status, highlight.format_highlight(is_focused, 'lualine_b'))
    table.insert(status, utils.draw_section(sections.lualine_b, M.separator))
  end
  if sections.lualine_c then
    table.insert(status, highlight.format_highlight(is_focused, 'lualine_c'))
    table.insert(status, utils.draw_section(sections.lualine_c, M.separator))
  end
  table.insert(status, "%=")
  if sections.lualine_x then
    table.insert(status, highlight.format_highlight(is_focused, 'lualine_c'))
    table.insert(status, utils.draw_section(sections.lualine_x, M.separator))
  end
  if sections.lualine_y then
    table.insert(status, highlight.format_highlight(is_focused, 'lualine_b'))
    table.insert(status, utils.draw_section(sections.lualine_y, M.separator))
  end
  if sections.lualine_z then
    table.insert(status, highlight.format_highlight(is_focused, 'lualine_a'))
    table.insert(status, utils.draw_section(sections.lualine_z, M.separator))
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
  load_components()
  load_extensions()
  set_lualine_theme()
  exec_autocommands()
  _G.lualine_statusline = status_dispatch
  vim.o.statusline = '%!v:lua.lualine_statusline()'
end

return M
