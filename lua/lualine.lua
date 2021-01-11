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

local function load_components()
  local function load_sections(sections)
    for _, section in pairs(sections) do
      for index, component in pairs(section) do
        if type(component) == 'string' then
          section[index] = require('lualine.components.' .. component)
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

local function statusline(is_focused)
  local sections = M.sections
  if not is_focused then
    sections = M.inactive_sections
  end
  if M.theme ~= theme_set then
    set_lualine_theme()
  end
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

function M.set_inactive_statusline()
  vim.wo.statusline = statusline()
end

local function exec_autocommands()
  _G.set_lualine_theme = set_lualine_theme
  _G.set_active_statusline = statusline
  vim.cmd([[augroup lualine]])
  vim.cmd([[autocmd!]])
  vim.cmd([[autocmd WinEnter,BufEnter * setlocal statusline=%!v:lua.set_active_statusline(1)]])
  vim.cmd([[autocmd WinLeave,BufLeave * lua require('lualine').set_inactive_statusline()]])
  vim.cmd([[autocmd ColorScheme * call v:lua.set_lualine_theme()]])
  vim.cmd([[augroup END]])
end

function M.status()
  load_components()
  load_extensions()
  set_lualine_theme()
  exec_autocommands()
end

return M
