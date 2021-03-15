-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = {}
local utils_colors = require 'lualine.utils.cterm_colors'
local utils = require 'lualine.utils.utils'
local section_highlight_map = {x = 'c', y = 'b', z = 'a'}

local function highlight(name, foreground, background, gui)
  local command = {'highlight', name}
  if foreground and foreground ~= 'none' then
    table.insert(command, 'ctermfg=' .. utils_colors.get_cterm_color(foreground))
    table.insert(command, 'guifg=' .. foreground)
  end
  if background and background ~= 'none' then
    table.insert(command, 'ctermbg=' .. utils_colors.get_cterm_color(background))
    table.insert(command, 'guibg=' .. background)
  end
  if gui then
    table.insert(command, 'cterm=' .. gui)
    table.insert(command, 'gui=' .. gui)
  end
  vim.cmd(table.concat(command, ' '))
  utils.save_highlight(name)
end

function M.create_highlight_groups(theme)
  for mode, sections in pairs(theme) do
    for section, colorscheme in pairs(sections) do
      local highlight_group_name = {'lualine', section, mode}
      highlight(table.concat(highlight_group_name, '_'), colorscheme.fg,
                colorscheme.bg, colorscheme.gui)
    end
  end
end

-- @description: adds '_mode' at end of highlight_group
-- @param highlight_group:(string) name of highlight group
-- @return: (string) highlight group name with mode
local function append_mode(highlight_group)
  local mode = require('lualine.components.mode')()
  if mode == 'VISUAL' or mode == 'V-BLOCK' or mode == 'V-LINE' or mode ==
      'SELECT' or mode == 'S-LINE' or mode == 'S-BLOCK' then
    highlight_group = highlight_group .. '_visual'
  elseif mode == 'REPLACE' or mode == 'V-REPLACE' then
    highlight_group = highlight_group .. '_replace'
  elseif mode == 'INSERT' then
    highlight_group = highlight_group .. '_insert'
  elseif mode == 'COMMAND' or mode == 'EX' or mode == 'MORE' or mode ==
      'CONFIRM' then
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
-- @return: (string) unique name that can be used by component_format_highlight
--   to retrive highlight group
function M.create_component_highlight_group(color, highlight_tag, options)
  if color.bg and color.fg then
    -- When bg and fg are both present we donn't need to set highlighs for
    -- each mode as they will surely look the same. So we can work without options
    local highlight_group_name = table.concat(
                                     {'lualine', highlight_tag, 'no_mode'}, '_')
    highlight(highlight_group_name, color.fg, color.bg, color.gui)
    return highlight_group_name
  end

  local modes = {
    'normal', 'insert', 'visual', 'replace', 'command', 'terminal', 'inactive'
  }
  local normal_hl
  -- convert lualine_a -> a before setting section
  local section = options.self.section:match('lualine_(.*)')
  if section > 'c' then section = section_highlight_map[section] end
  for _, mode in ipairs(modes) do
    local highlight_group_name = {options.self.section, highlight_tag, mode}
    local default_color_table = options.theme[mode] and
                                    options.theme[mode][section] or
                                    options.theme.normal[section]
    local bg = (color.bg or default_color_table.bg)
    local fg = (color.fg or default_color_table.fg)
    -- Check if it's same as normal mode if it is no need to create aditional highlight
    if mode ~= 'normal' then
      if bg ~= normal_hl.bg or fg ~= normal_hl.fg then
        highlight(table.concat(highlight_group_name, '_'), fg, bg, color.gui)
      end
    else
      normal_hl = {bg = bg, fg = fg}
      highlight(table.concat(highlight_group_name, '_'), fg, bg, color.gui)
    end
  end
  return options.self.section .. '_' .. highlight_tag
end

-- @description: retrieve highlight_groups for components
-- @param highlight_name:(string) highlight group name without mode
--   return value of create_component_highlight_group is to be passed in
--   this parameter to receive highlight that was created
-- @return: (string) formated highlight group name
function M.component_format_highlight(highlight_name)
  local highlight_group = highlight_name
  if highlight_name:find('no_mode') == #highlight_name - #'no_mode' + 1 then
    return '%#' .. highlight_group .. '#'
  end
  if vim.g.statusline_winid == vim.fn.win_getid() then
    highlight_group = append_mode(highlight_group)
  else
    highlight_group = highlight_group .. '_inactive'
  end
  if utils.highlight_exists(highlight_group) then
    return '%#' .. highlight_group .. '#'
  else
    return '%#' .. highlight_name .. '_normal#'
  end
end

function M.format_highlight(is_focused, highlight_group)
  if highlight_group > 'lualine_c' then
    highlight_group = 'lualine_' ..
                          section_highlight_map[highlight_group:match(
                              'lualine_(.)')]
  end
  local highlight_name = highlight_group
  if not is_focused then
    highlight_name = highlight_group .. [[_inactive]]
  else
    highlight_name = append_mode(highlight_group)
  end
  if utils.highlight_exists(highlight_name) then
    return '%#' .. highlight_name .. '#'
  end
  return '%#' .. highlight_group .. '_normal#'
end

-- @description : Provides transitional highlights for section separators.
-- @param left_section_data :(string) section before separator
-- @param right_section_data:(string) section after separator
-- @param reverse      :(string) Whether it's a left separator or right separator
--    '▶️' and '◀️' needs reverse colors so this parameter needs to be set true.
-- @return: (string) formated highlight group name
function M.get_transitional_highlights(left_section_data, right_section_data,
                                       reverse)
  local left_highlight_name, right_highlight_name
  -- Grab the last highlighter of left section
  if left_section_data then
    -- extract highlight_name from .....%#highlight_name#
    left_highlight_name = left_section_data:match('.*%%#(.*)#')
  else
    -- When right section us unavailable default to lualine_c
    left_highlight_name = append_mode('lualine_c')
    if not utils.highlight_exists(left_highlight_name) then
      left_highlight_name = 'lualine_c_normal'
    end
  end
  if right_section_data then
    -- using vim-regex cause lua-paterns don't have non-greedy matching
    -- extract highlight_name from %#highlight_name#....
    right_highlight_name = vim.fn.matchlist(right_section_data,
                                            [[%#\(.\{-\}\)#]])[2]
  else
    -- When right section us unavailable default to lualine_c
    right_highlight_name = append_mode('lualine_c')
    if not utils.highlight_exists(right_highlight_name) then
      right_highlight_name = 'lualine_c_normal'
    end
  end
  -- When both left and right highlights are same nothing to transition to
  if left_highlight_name == right_highlight_name then return end

  -- construct the name of hightlight group
  local highlight_name
  if left_highlight_name:find('lualine_') == 1 then
    highlight_name = left_highlight_name .. '_to_' .. right_highlight_name
  else
    highlight_name = 'lualine_' .. left_highlight_name .. '_to_' ..
                         right_highlight_name
  end

  if not utils.highlight_exists(highlight_name) then
    -- Create the highlight_group if needed
    local function set_transitional_highlights()
      -- Get colors from highlights
      -- using string.format to convert decimal to hexadecimal
      local fg = utils.extract_highlight_colors(left_highlight_name, 'guibg')
      local bg = utils.extract_highlight_colors(right_highlight_name, 'guibg')
      if not fg then fg = 'none' end
      if not bg then bg = 'none' end
      -- swap the bg and fg when reverse is true. As in that case highlight will
      -- be placed before section
      if reverse then fg, bg = bg, fg end
      highlight(highlight_name, fg, bg)
    end
    -- Create highlights and setup to survive colorscheme changes
    set_transitional_highlights()
    utils.expand_set_theme(set_transitional_highlights)
  end
  return '%#' .. highlight_name .. '#'
end

return M
