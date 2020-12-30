local M = {  }

local function highlight (name, foreground, background, special)
  if special == nil then
    special = 'none'
  end
  local command = 'highlight '
  command = command .. name .. ' '
  command = command .. 'guifg=' .. foreground .. ' '
  command = command .. 'guibg=' .. background .. ' '
  if special then
    command = command .. 'gui=' .. special .. ' '
  end
  return command
end

function M.createHighlightGroups(theme)
  for mode, sections in pairs(theme) do
    for section, colorscheme in pairs(sections) do
      if section == 'a' then
        vim.cmd(highlight('lualine_' .. section .. '_' .. mode, colorscheme.fg, colorscheme.bg ,'bold'))
      else
        vim.cmd(highlight('lualine_' .. section .. '_' .. mode, colorscheme.fg, colorscheme.bg ))
      end
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
