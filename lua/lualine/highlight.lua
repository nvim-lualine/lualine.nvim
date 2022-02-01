-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = {}
local lualine_require = require('lualine_require')
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
  end
  loaded_highlights = {}
end

---converts cterm, color_name type colors to #rrggbb format
---@param color string|number
---@return string
local function sanitize_color(color)
  if color == '' then
    return nil
  end
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
    if loaded_highlights[name] and loaded_highlights[name].link == link then
      return
    end
    vim.list_extend(command, { 'link', name, link })
  else
    foreground = sanitize_color(foreground)
    background = sanitize_color(background)
    if
      loaded_highlights[name]
      and loaded_highlights[name].fg == foreground
      and loaded_highlights[name].bg == background
      and loaded_highlights[name].gui == gui
    then
      return -- color is already defined why are we doing this anyway ?
    end
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
    if gui and gui ~= '' then
      table.insert(command, 'cterm=' .. gui)
      table.insert(command, 'gui=' .. gui)
    end
  end
  vim.cmd(table.concat(command, ' '))

  -- update attached hl groups
  local old_hl_def = loaded_highlights[name]
  if old_hl_def and #old_hl_def.attached > 0 then
    local bg_changed = old_hl_def.bg ~= background
    local fg_changed = old_hl_def.bg ~= foreground
    for attach_name, attach_desc in pairs(old_hl_def.attached) do
      if bg_changed and attach_desc.bg and loaded_highlights[attach_name] then
        M.highlight(
          attach_name,
          attach_desc.bg == 'fg' and background or loaded_highlights[attach_name].fg,
          attach_desc.bg == 'bg' and background or loaded_highlights[attach_name].bg,
          loaded_highlights[attach_name].gui,
          loaded_highlights[attach_name].link
        )
      end
      if fg_changed and attach_desc.fg and loaded_highlights[attach_name] then
        M.highlight(
          attach_name,
          attach_desc.fg == 'fg' and foreground or loaded_highlights[attach_name].fg,
          attach_desc.fg == 'bg' and foreground or loaded_highlights[attach_name].bg,
          loaded_highlights[attach_name].gui,
          loaded_highlights[attach_name].link
        )
      end
    end
  end
  -- store current hl state
  loaded_highlights[name] = {
    fg = foreground,
    bg = background,
    gui = gui,
    link = link,
    attached = old_hl_def and old_hl_def.attached or {},
  }
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
---@param mode string mode which default component color should be given.
---@param section string the lualine section component is in.
---@param color table color passed for creating component highlight
---@param options_color table color set by color option for component
---       this is first fall back
local function get_default_component_color(mode, section, color, options_color)
  local default_color = active_theme[mode] and active_theme[mode][section] or active_theme.normal[section]
  local ret = { fg = color.fg, bg = color.bg }
  if ret.fg and ret.bg then
    return ret
  end
  if options_color then
    if type(options_color) == 'string' then
      options_color = modules.utils.extract_highlight_colors(options_color)
    elseif type(options_color) == 'function' then
      options_color = options_color(mode, section)
    end
    if type(options_color) == 'table' then
      if not ret.fg and options_color.fg then
        ret.fg = options_color.fg
      end
      if not ret.bg and options_color.bg then
        ret.bg = options_color.bg
      end
    end
  end
  if ret.fg and ret.bg then
    return ret
  end
  if type(default_color) == 'string' then
    default_color = modules.utils.extract_highlight_colors(default_color)
  end
  if type(default_color) == 'table' then
    if not ret.fg and default_color.fg then
      ret.fg = default_color.fg
    end
    if not ret.bg and default_color.bg then
      ret.bg = default_color.bg
    end
  end
  return ret
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
  -- convert lualine_a -> a before setting section
  local section = options.self.section:match('lualine_(.*)')
  if section > 'c' and not active_theme.normal[section] then
    section = section_highlight_map[section]
  end
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
    return { name = highlight_group_name, no_mode = true }
  end
  if type(color) == 'function' then
    local highlight_group_name = table.concat({ 'lualine', highlight_tag }, '_')
    return {
      name = highlight_group_name,
      fn = color,
      no_mode = false,
      section = section,
      component_color = color ~= options.color and options.color,
    }
  end
  if color.bg and color.fg then
    -- When bg and fg are both present we donn't need to set highlighs for
    -- each mode as they will surely look the same. So we can work without options
    local highlight_group_name = table.concat({ 'lualine', highlight_tag, 'no_mode' }, '_')
    M.highlight(highlight_group_name, color.fg, color.bg, color.gui, nil)
    return { name = highlight_group_name, no_mode = true, section = section }
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
  for _, mode in ipairs(modes) do
    local highlight_group_name = { options.self.section, highlight_tag, mode }
    local cl = get_default_component_color(mode, section, color, options.color)
    M.highlight(table.concat(highlight_group_name, '_'), cl.fg, cl.bg, color.gui, nil)
  end
  return {
    name = options.self.section .. '_' .. highlight_tag,
    no_mode = false,
    section = section,
  }
end

---@description: retrieve highlight_groups for components
---@param highlight string highlight group name without mode
---  return value of create_component_highlight_group is to be passed in
---  this parameter to receive highlight that was created
---@return string formatted highlight group name
function M.component_format_highlight(highlight)
  if not highlight.fn then
    local highlight_group = highlight.name
    if highlight.no_mode then
      return '%#' .. highlight_group .. '#'
    end
    highlight_group = M.append_mode(highlight_group)
    return '%#' .. highlight_group .. '#'
  else
    local mode = require('lualine.utils.mode').get_mode()
    local color = highlight.fn { mode = mode, section = highlight.section }
    if type(color) == 'string' then
      local hl_name = highlight.name .. '_no_mode'
      M.highlight(hl_name, nil, nil, nil, color)
      return '%#' .. hl_name .. '#'
    elseif type(color) == 'table' then
      local hl_name = highlight.name .. '_no_mode'
      if not color.fg or not color.bg then
        hl_name = M.append_mode(highlight.name)
        color = get_default_component_color(mode, highlight.section, color, highlight.component_color)
      end
      M.highlight(hl_name, color.fg, color.bg, color.gui, nil)
      return '%#' .. hl_name .. '#'
    end
  end
end

---@description: retrieve highlight_groups for section
---@param highlight_group string highlight group name without mode
---  return value of create_component_highlight_group is to be passed in
---  this parameter to receive highlight that was created
---@param is_focused boolean
---@return string formatted highlight group name
function M.format_highlight(highlight_group, is_focused)
  local highlight_name = M.append_mode(highlight_group, is_focused)
  if highlight_group > 'lualine_c' and not M.highlight_exists(highlight_name) then
    highlight_group = 'lualine_' .. section_highlight_map[highlight_group:match('lualine_(.)')]
    highlight_name = M.append_mode(highlight_group, is_focused)
  end
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
    if not fg and not bg then
      return nil -- Color retrieval failed
    end
    if bg == fg then
      return nil -- Separator won't be visible anyway
    end
    M.highlight(highlight_name, fg, bg, nil)
    loaded_highlights[left_hl].attached[highlight_name] = { bg = 'fg' }
    loaded_highlights[right_hl].attached[highlight_name] = { fg = 'bg' }
  end
  return '%#' .. highlight_name .. '#'
end

return M
