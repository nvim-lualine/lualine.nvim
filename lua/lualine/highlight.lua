local M = {  }

local function get_cterm_color(color)
  local function round(num)
    if num - math.floor(num) < 0.5000000 then
      return math.floor(num)
    else
      return math.ceil(num)
    end
  end

  local r = tonumber(color:sub(2,3), 16)
  local g = tonumber(color:sub(4,5), 16)
  local b = tonumber(color:sub(6,7), 16)
  return 36 * round(r * 5/256) + 6 * round(g * 5/256) +round(b * 5 / 256) + 16
end

local function highlight (name, foreground, background, gui)
  local command = {}
    command = {
      'highlight', name,
      'ctermfg=' .. (foreground[2] or get_cterm_color(foreground)),
      'ctermbg=' .. (background[2] or get_cterm_color(background)),
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
      local gui = colorscheme.gui
      if section == 'a' and gui == nil then
        gui = 'bold'
      end
      local highlight_group_name = { 'lualine', section, mode }
      vim.cmd(highlight(table.concat(highlight_group_name, '_'), colorscheme.fg, colorscheme.bg, gui))
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
    elseif mode == 'SELECT' then
      highlight_group = highlight_group .. '_terminal'
    else
      highlight_group = highlight_group .. '_' .. mode:lower()
    end
  end
  highlight_group = highlight_group .. [[#]]
  return highlight_group
end

return M
