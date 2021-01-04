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
  lualine_diagnostics = {  }
}

M.inactiveSections = {
  lualine_a = {  },
  lualine_b = {  },
  lualine_c = { 'filename' },
  lualine_x = { 'location' },
  lualine_y = {  },
  lualine_z = {   }
}

M.extensions = {
}

local function loadComponents()
  local function loadSections(sections)
    for _, section in pairs(sections) do
      for index, component in pairs(section) do
        if type(component) == 'string' then
          section[index] = require('lualine.components.' .. component)
        end
      end
    end
  end
  loadSections(M.sections)
  loadSections(M.inactiveSections)
end

local function  loadExtensions()
  for _, extension in pairs(M.extensions) do
    if type(extension) == 'string' then
      require('lualine.components.extensions.' .. extension).loadExtension()
    end
    if type(extension) == 'table' then
      extension.loadExtension()
    end
    if type(extension) == 'function' then
      extension()
    end
  end
end

local function setLualineTheme()
  if type(M.theme) == 'string' then
    M.theme =require('lualine.themes.'.. M.theme)
  end
  highlight.createHighlightGroups(M.theme)
  theme_set = M.theme
end

local function StatusLine(isFocused)
  local sections = M.sections
  if not isFocused then
    sections = M.inactiveSections
  end
  if M.theme ~= theme_set then
    setLualineTheme()
  end
  local status = {}
  if sections.lualine_a ~= nil then
    table.insert(status, highlight.formatHighlight(isFocused, 'lualine_a'))
    table.insert(status, utils.drawSection(sections.lualine_a, M.separator))
  end
  if sections.lualine_b ~= nil then
    table.insert(status, highlight.formatHighlight(isFocused, 'lualine_b'))
    table.insert(status, utils.drawSection(sections.lualine_b, M.separator))
  end
  if sections.lualine_c ~= nil then
    table.insert(status, highlight.formatHighlight(isFocused, 'lualine_c'))
    table.insert(status, utils.drawSection(sections.lualine_c, M.separator))
  end
  table.insert(status, "%=")
  if sections.lualine_x ~= nil then
    table.insert(status, highlight.formatHighlight(isFocused, 'lualine_c'))
    table.insert(status, utils.drawSection(sections.lualine_x, M.separator))
  end
  if sections.lualine_y ~= nil then
    table.insert(status, highlight.formatHighlight(isFocused, 'lualine_b'))
    table.insert(status, utils.drawSection(sections.lualine_y, M.separator))
  end
  if sections.lualine_z ~= nil then
    table.insert(status, highlight.formatHighlight(isFocused, 'lualine_a'))
    table.insert(status, utils.drawSection(sections.lualine_z, M.separator))
  end
  return table.concat(status)
end

function execAutocommands()
  _G.statusline = StatusLine
  _G.highlight = setLualineTheme
  vim.cmd([[autocmd WinEnter,BufEnter * setlocal statusline=%!v:lua.statusline(1)]])
  vim.cmd([[autocmd WinLeave,BufLeave * setlocal statusline=%!v:lua.statusline()]])
  vim.cmd([[autocmd ColorScheme * call v:lua.highlight()]])
end

function M.status()
  loadComponents()
  loadExtensions()
  setLualineTheme()
  execAutocommands()
end

return M
