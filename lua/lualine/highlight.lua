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

function M.createHighlightGroups(theme)
  for mode, sections in pairs(theme) do
    for section, colorscheme in pairs(sections) do
      local special = nil
      if section == 'a' then
        special = 'bold'
      end
      vim.cmd(highlight('lualine_' .. section .. '_' .. mode, colorscheme.fg, colorscheme.bg, special))
    end
  end
end

function M.formatHighlight(isFocused, highlighGroup)
  local mode = require('lualine.components.mode')()
  highlighGroup = [[%#]] .. highlighGroup
  if not isFocused then
    highlighGroup = highlighGroup .. [[_inactive]]
  else
    if mode == 'V-BLOCK' or mode == 'V-LINE' then
      highlighGroup = highlighGroup .. '_visual'
    elseif mode == 'V-REPLACE' then
      highlighGroup = highlighGroup .. '_replace'
    else
      highlighGroup = highlighGroup .. '_' .. mode:lower()
    end
  end
  highlighGroup = highlighGroup .. [[#]]
  return highlighGroup
end

return M
