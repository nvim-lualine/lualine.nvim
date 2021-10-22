-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = {}
local lualine_require = require 'lualine_require'
local require = lualine_require.require
local modules = lualine_require.lazy_require {
  utils = 'lualine.utils.utils',
  color_utils = 'lualine.utils.color_utils',
}

local section_highlight_map = { x = 'c', y = 'b', z = 'a' }
local active_theme = nil
local create_cterm_colors = false

-- table to store the highlight names created by lualine
local loaded_highlights = {}

-- table to map mode to highlight suffixes
local mode_to_highlight = {
  ['VISUAL'] = '_visual',
  ['V-BLOCK'] = '_visual',
  ['V-LINE'] = '_visual',
  ['SELECT'] = '_visual',
  ['S-LINE'] = '_visual',
  ['S-BLOCK'] = '_visual',
  ['REPLACE'] = '_replace',
  ['V-REPLACE'] = '_replace',
  ['INSERT'] = '_insert',
  ['COMMAND'] = '_command',
  ['EX'] = '_command',
  ['MORE'] = '_command',
  ['CONFIRM'] = '_command',
  ['TERMINAL'] = '_terminal',
}

--- determine if an highlight exist and isn't cleared
---@param highlight_name string
---@return boolean whether hl_group was defined with highlight_name
function M.highlight_exists(highlight_name)
  return loaded_highlights[highlight_name] or false
end

--- clears loaded_highlights table and highlights
local function clear_highlights()
  for highlight_name, _ in pairs(loaded_highlights) do
    vim.cmd('highlight clear ' .. highlight_name)
    loaded_highlights[highlight_name] = nil
  end
end

---converts cterm, color_name type colors to #rrggbb format
---@param color string|number
---@return string
local function sanitize_color(color)
  if type(color) == 'string' then
    if color:sub(1, 1) == '#' then
      return color
    end -- RGB value
    return modules.color_utils.color_name2rgb(color)
  elseif type(color) == 'number' then
    if color > 255 then
      error("What's this it can't be higher then 255 and you've given " .. color)
    end
    return modules.color_utils.cterm2rgb(color)
  end
end

--- Define a hl_group
---@param name string
---@param foreground string|number: color
---@param background string|number: color
---@param gui table cterm/gui options like bold/italic ect
---@param link string hl_group name to link new hl to
function M.highlight(name, foreground, background, gui, link)
  local command = { 'highlight!' }
  if link and #link > 0 then
    vim.list_extend(command, { 'link', name, link })
  else
    foreground = sanitize_color(foreground)
    background = sanitize_color(background)
    table.insert(command, name)
    if foreground and foreground ~= 'None' then
      table.insert(command, 'guifg=' .. foreground)
      if create_cterm_colors then
        table.insert(command, 'ctermfg=' .. modules.color_utils.rgb2cterm(foreground))
      end
    end
    if background and background ~= 'None' then
      table.insert(command, 'guibg=' .. background)
      if create_cterm_colors then
        table.insert(command, 'ctermbg=' .. modules.color_utils.rgb2cterm(background))
      end
    end
    if gui then
      table.insert(command, 'cterm=' .. gui)
      table.insert(command, 'gui=' .. gui)
    end
  end
  vim.cmd(table.concat(command, ' '))
  loaded_highlights[name] = true
end

---define hl_groups for a theme
---@param theme table
function M.create_highlight_groups(theme)
  clear_highlights()
  active_theme = theme
  create_cterm_colors = not vim.go.termguicolors
  for mode, sections in pairs(theme) do
    for section, color in pairs(sections) do
      local highlight_group_name = { 'lualine', section, mode }
      if type(color) == 'string' then -- link to a highlight group
        M.highlight(table.concat(highlight_group_name, '_'), nil, nil, nil, color)
      else -- Define a new highlight
        M.highlight(table.concat(highlight_group_name, '_'), color.fg, color.bg, color.gui, nil)
      end
    end
  end
end

---@description: adds '_mode' at end of highlight_group
---@param highlight_group string name of highlight group
---@return string highlight group name with mode
function M.append_mode(highlight_group, is_focused)
  if is_focused == nil then
    is_focused = modules.utils.is_focused()
  end
  if is_focused == false then
    return highlight_group .. '_inactive'
  end
  local mode = require('lualine.utils.mode').get_mode()
  return highlight_group .. (mode_to_highlight[mode] or '_normal')
end

-- Helper function for create component highlight
---Handles fall back of colors when creating highlight group
---@param color table color passed for creating component highlight
---@param options_color table color set by color option for component
---       this is first fall back
---@param default_color table colors et in theme this is 2nd fall back
---@param kind string fg/bg
local function get_default_component_color(color, options_color, default_color, kind)
  if color[kind] then
    return color[kind]
  end
  if options_color then
    if type(options_color) == 'table' and options_color[kind] then
      return options_color[kind]
    elseif type(options_color) == 'string' then
      return modules.utils.extract_highlight_colors(options_color, kind)
    end
  end
  if type(default_color) == 'table' then
    return default_color[kind]
  elseif type(default_color) == 'string' then
    return modules.utils.extract_highlight_colors(default_color, kind)
  end
end

---Create highlight group with fg bg and gui from theme
---@param color table has to be { fg = "#rrggbb", bg="#rrggbb" gui = "effect" }
---       all the color elements are optional if fg or bg is not given options
---       must be provided So fg and bg can default the themes colors
---@param highlight_tag string is unique tag for highlight group
---returns the name of highlight group
---@param options table is parameter of component.init() function
---@return string unique name that can be used by component_format_highlight
---  to retrieve highlight group
function M.create_component_highlight_group(color, highlight_tag, options)
  local tag_id = 0
  while
    M.highlight_exists(table.concat({ 'lualine', highlight_tag, 'no_mode' }, '_'))
    or (
      options.self.section
      and M.highlight_exists(table.concat({ options.self.section, highlight_tag, 'normal' }, '_'))
    )
  do
    highlight_tag = highlight_tag .. '_' .. tostring(tag_id)
    tag_id = tag_id + 1
  end
  if type(color) == 'string' then
    local highlight_group_name = table.concat({ 'lualine', highlight_tag, 'no_mode' }, '_')
    M.highlight(highlight_group_name, nil, nil, nil, color) -- l8nk to group
    return highlight_group_name
  end
  if color.bg and color.fg then
    -- When bg and fg are both present we donn't need to set highlighs for
    -- each mode as they will surely look the same. So we can work without options
    local highlight_group_name = table.concat({ 'lualine', highlight_tag, 'no_mode' }, '_')
    M.highlight(highlight_group_name, color.fg, color.bg, color.gui, nil)
    return highlight_group_name
  end

  local modes = {
    'normal',
    'insert',
    'visual',
    'replace',
    'command',
    'terminal',
    'inactive',
  }
  local normal_hl
  -- convert lualine_a -> a before setting section
  local section = options.self.section:match 'lualine_(.*)'
  if section > 'c' and not active_theme.normal[section] then
    section = section_highlight_map[section]
  end
  for _, mode in ipairs(modes) do
    local highlight_group_name = { options.self.section, highlight_tag, mode }
    local default_color_table = active_theme[mode] and active_theme[mode][section] or active_theme.normal[section]
    local bg = get_default_component_color(color, options.color, default_color_table, 'bg')
    local fg = get_default_component_color(color, options.color, default_color_table, 'fg')
    -- Check if it's same as normal mode if it is no need to create aditional highlight
    if mode ~= 'normal' then
      if bg ~= normal_hl.bg or fg ~= normal_hl.fg then
        M.highlight(table.concat(highlight_group_name, '_'), fg, bg, color.gui, nil)
      end
    else
      normal_hl = { bg = bg, fg = fg }
      M.highlight(table.concat(highlight_group_name, '_'), fg, bg, color.gui, nil)
    end
  end
  return options.self.section .. '_' .. highlight_tag
end

---@description: retrieve highlight_groups for components
---@param highlight_name string highlight group name without mode
---  return value of create_component_highlight_group is to be passed in
---  this parameter to receive highlight that was created
---@return string formatted highlight group name
function M.component_format_highlight(highlight_name)
  local highlight_group = highlight_name
  if highlight_name:find 'no_mode' == #highlight_name - #'no_mode' + 1 then
    return '%#' .. highlight_group .. '#'
  end
  highlight_group = M.append_mode(highlight_group)
  if M.highlight_exists(highlight_group) then
    return '%#' .. highlight_group .. '#'
  else
    return '%#' .. highlight_name .. '_normal#'
  end
end

---@description: retrieve highlight_groups for section
---@param highlight_group string highlight group name without mode
---  return value of create_component_highlight_group is to be passed in
---  this parameter to receive highlight that was created
---@param is_focused boolean
---@return string formatted highlight group name
function M.format_highlight(highlight_group, is_focused)
  if highlight_group > 'lualine_c' and not M.highlight_exists(highlight_group .. '_normal') then
    highlight_group = 'lualine_' .. section_highlight_map[highlight_group:match 'lualine_(.)']
  end
  local highlight_name
  highlight_name = M.append_mode(highlight_group, is_focused)
  if M.highlight_exists(highlight_name) then
    return '%#' .. highlight_name .. '#'
  end
  return '%#' .. highlight_group .. '_normal#'
end

---@description : Provides transitional highlights for section separators.
---@param left_hl string this highlights bg is used for fg of transitional hl
---@param right_hl string this highlights bg is used for bg of transitional hl
---   '▶️' and '◀️' ' needs reverse colors so the caller should swap left and right
---@return string formatted highlight group name
function M.get_transitional_highlights(left_hl, right_hl)
  -- When both left and right highlights are same or one is absent
  -- nothing to transition to.
  if left_hl == nil or right_hl == nil or left_hl == right_hl then
    return nil
  end

  -- construct the name of highlight group
  local highlight_name = table.concat({ 'lualine_transitional', left_hl, 'to', right_hl }, '_')
  if not M.highlight_exists(highlight_name) then
    -- Create the highlight_group if needed
    -- Get colors from highlights
    local fg = modules.utils.extract_highlight_colors(left_hl, 'bg')
    local bg = modules.utils.extract_highlight_colors(right_hl, 'bg')
    if not fg or not bg then
      return nil
    end -- Color retrieval failed
    if bg == fg then
      return nil
    end -- Separator won't be visible anyway
    M.highlight(highlight_name, fg, bg, nil)
  end
  return '%#' .. highlight_name .. '#'
end

return M
