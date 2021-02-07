local utils
local highlight

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
  local async_loader
  async_loader = vim.loop.new_async(vim.schedule_wrap(function()
    utils = require('lualine.utils')
    highlight = require('lualine.highlight')
    exec_autocommands()
    set_lualine_theme()
    load_components()
    load_extensions()
    _G.lualine_statusline = status_dispatch
    vim.o.statusline = '%!v:lua.lualine_statusline()'
    async_loader:close()
  end))
  async_loader:send()
end

return M
