-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local M = {  }
local utils = require "lualine.utils"

local function highlight (name, foreground, background, gui)
  local command = {
      'highlight', name,
      'ctermfg=' .. (foreground[2] or utils.get_cterm_color(foreground)),
      'ctermbg=' .. (background[2] or utils.get_cterm_color(background)),
      'cterm=' .. (gui or 'none'),
      'guifg=' .. (foreground[1] or foreground),
      'guibg=' .. (background[1] or background),
      'gui=' .. (gui or 'none'),
    }
  return table.concat(command, ' ')
end

local function apply_defaults_to_theme(theme)
  local modes = {'insert', 'visual', 'replace', 'command', 'terminal', 'inactive'}
  for _, mode in ipairs(modes) do
    if not theme[mode] then
      theme[mode] = theme['normal']
    else
      for section_name, section in pairs(theme['normal']) do
        theme[mode][section_name] = (theme[mode][section_name] or section)
      end
    end
  end
  return theme
end

function M.create_highlight_groups(theme)
  apply_defaults_to_theme(theme)
  for mode, sections in pairs(theme) do
    for section, colorscheme in pairs(sections) do
      local highlight_group_name = { 'lualine', section, mode }
      vim.cmd(highlight(table.concat(highlight_group_name, '_'), colorscheme.fg, colorscheme.bg, colorscheme.gui))
    end
  end
end

function M.format_highlight(is_focused, highlight_group)
  local mode = require('lualine.components.mode')()
  highlight_group = [[%#]] .. highlight_group
  if not is_focused then
    highlight_group = highlight_group .. [[_inactive]]
  else
    if mode == 'VISUAL' or mode == 'V-BLOCK' or mode == 'V-LINE'
      or mode == 'SELECT' or mode == 'S-LINE' or mode == 'S-BLOCK'then
      highlight_group = highlight_group .. '_visual'
    elseif mode == 'REPLACE' or mode == 'V-REPLACE' then
      highlight_group = highlight_group .. '_replace'
    elseif mode == 'INSERT' then
      highlight_group = highlight_group .. '_insert'
    elseif mode == 'COMMAND' or mode == 'EX' or mode == 'MORE' or mode == 'CONFIRM'then
      highlight_group = highlight_group .. '_command'
    elseif mode == 'TERMINAL' then
      highlight_group = highlight_group .. '_terminal'
    else
      highlight_group = highlight_group .. '_normal'
    end
  end
  highlight_group = highlight_group .. [[#]]
  return highlight_group
end

return M
