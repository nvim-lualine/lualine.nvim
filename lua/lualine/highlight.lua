local M = {  }

local function highlight (name, foreground, background, special)
  local command = {
    'highlight', name,
    'guifg=' .. foreground,
    'guibg=' .. background,
    'gui=' .. (special or 'none'),
  }
  return table.concat(command, ' ')
end

local function apply_defaults_to_theme(theme)
  local modes = {'insert', 'visual', 'replace', 'command', 'terminal', 'inactive'}
  for _, mode in ipairs(modes) do
    theme[mode] = (theme[mode] or theme['normal'])
    theme[mode]['a'] = (theme[mode]['a'] or theme['normal']['a'])
    theme[mode]['b'] = (theme[mode]['b'] or theme['normal']['b'])
    theme[mode]['c'] = (theme[mode]['c'] or theme['normal']['c'])
  end
  return theme
end

function M.create_highlight_groups(theme)
  apply_defaults_to_theme(theme)
  for mode, sections in pairs(theme) do
    for section, colorscheme in pairs(sections) do
      local special = nil
      if section == 'a' then
        special = 'bold'
      end
      local highlight_group_name = { 'lualine', section, mode }
      vim.cmd(highlight(table.concat(highlight_group_name, '_'), colorscheme.fg, colorscheme.bg, special))
    end
  end
end

function M.format_highlight(is_focused, highlight_group)
  local mode = require('lualine.components.mode')()
  highlight_group = [[%#]] .. highlight_group
  if not is_focused then
    highlight_group = highlight_group .. [[_inactive]]
  else
    if mode == 'V-BLOCK' or mode == 'V-LINE' then
      highlight_group = highlight_group .. '_visual'
    elseif mode == 'V-REPLACE' then
      highlight_group = highlight_group .. '_replace'
    else
      highlight_group = highlight_group .. '_' .. mode:lower()
    end
  end
  highlight_group = highlight_group .. [[#]]
  return highlight_group
end

return M
