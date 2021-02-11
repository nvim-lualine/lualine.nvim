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

local function append_mode(highlight_group)
  local mode = require('lualine.components.mode')()
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
  return highlight_group
end

-- Create highlight group with fg bg and gui from theme
-- section and theme are extracted from @options.self table
-- @@color has to be { fg = "#rrggbb", bg="#rrggbb" gui = "effect" }
-- all the color elements are optional if fg or bg is not given options must be provided
-- So fg and bg can default the themes colors
-- @@highlight_tag is unique tag for highlight group
-- returns the name of highlight group
-- @@options is parameter of component.init() function
function M.create_component_highlight_group(color , highlight_tag, options)
  if color.bg and color.fg then
    -- When bg and fg are both present we donn't need to set highlighs for
    -- each mode as they will surely look the same
    local highlight_group_name = table.concat({ 'lualine', highlight_tag, 'no_mode'}, '_')
    vim.cmd(highlight(highlight_group_name, color.fg, color.bg, color.gui))
    return highlight_group_name
  end

  local modes = {'normal', 'insert', 'visual', 'replace', 'command', 'terminal', 'inactive'}
  for _, mode in ipairs(modes) do
    local highlight_group_name = { options.self.section, highlight_tag, mode }
    -- convert lualine_a -> a before setting section
    local section = options.self.section:match('lualine_(.*)')
    local bg = (color.bg or options.theme[mode][section]['bg'])
    local fg = (color.fg or options.theme[mode][section]['fg'])
    vim.cmd(highlight(table.concat(highlight_group_name, '_'), fg, bg, color.gui))
  end
  return options.self.section..'_'..highlight_tag
end

-- retrieve highlight_groups for components
-- @@highlight_name received from create_component_highlight_group
function M.component_format_highlight(highlight_name)
  local highlight_group = [[%#]]..highlight_name
  if highlight_name:find('no_mode') == #highlight_name - #'no_mode' + 1 then
    return highlight_group..'#'
  end
  if vim.g.statusline_winid == vim.fn.win_getid() then
    highlight_group = append_mode(highlight_group)..'#'
  else
    highlight_group = highlight_group..'_inactive'..'#'
  end
  return highlight_group
end

function M.format_highlight(is_focused, highlight_group)
  highlight_group = [[%#]] .. highlight_group
  if not is_focused then
    highlight_group = highlight_group .. [[_inactive]]
  else
    highlight_group = append_mode(highlight_group)
  end
  highlight_group = highlight_group .. [[#]]
  return highlight_group
end

return M
