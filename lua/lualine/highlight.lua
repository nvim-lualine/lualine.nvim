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
  -- normal mode cann't have a fallback for now
  local sections = {'a', 'b', 'c'}
  for _, mode in ipairs(modes) do
    repeat
      if theme[mode] == nil then
        theme[mode] = theme['normal']
        break
      end
      for _, section in ipairs(sections) do
        repeat
          if theme[mode][section] == nil then
            theme[mode][section] = theme['normal'][section]
            break
          end
          break
        until true
      end
      break
    until true
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
