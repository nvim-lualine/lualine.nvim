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
local theme_hls = {}
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
  theme_hls = {}
  local psudo_options = { self = { section = 'lualine_a' } }
  create_cterm_colors = not vim.go.termguicolors
  for mode, sections in pairs(theme) do
    theme_hls[mode] = {}
    for section, color in pairs(sections) do
      local hl_tag = table.concat({ section, mode }, '_')
      psudo_options.self.section = 'lualine_' .. section
      theme_hls[mode][section] = M.create_component_highlight_group(color, hl_tag, psudo_options, true)
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
---@param options.color table color set by color option for component
---       this is first fall back
local function get_default_component_color(hl_name, mode, section, color, options)
  local default_color = active_theme[mode] and active_theme[mode][section] or active_theme.normal[section]
  local ret = { fg = color.fg, bg = color.bg }
  if ret.fg and ret.bg then
    return ret
  end
  if options.color and options.color_highlight
    and  options.color_highlight.name ~= hl_name then
    if type(options.color) == 'string' then
      options.color = modules.utils.extract_highlight_colors(options.color)
    elseif type(options.color) == 'function' then
      options.color = options.color(mode, section)
    end
    local options_hl_name = M.append_mode(options.color_highlight.name)
    if type(options.color) == 'table' then
      if not ret.fg and options.color.fg then
        ret.fg = options.color.fg
        if loaded_highlights[options_hl_name] then
          loaded_highlights[options_hl_name].attached[hl_name] = { fg = 'fg' }
        end
      end
      if not ret.bg and options.color.bg then
        ret.bg = options.color.bg
        if loaded_highlights[options_hl_name] then
          loaded_highlights[options_hl_name].attached[hl_name] = { bg = 'bg' }
        end
      end
    end
  end
  if ret.fg and ret.bg then
    return ret
  end
  if type(default_color) == 'string' then
    default_color = modules.utils.extract_highlight_colors(default_color)
  elseif type(default_color) == 'function' then
    default_color = default_color(mode, section)
  end
  local default_hl_name = string.format('lualine_%s_%s', section, mode)
  if type(default_color) == 'table' then
    if not ret.fg and default_color.fg then
      ret.fg = default_color.fg
      if loaded_highlights[default_hl_name] then
        loaded_highlights[default_hl_name].attached[hl_name] = { fg = 'fg' }
      end
    end
    if not ret.bg and default_color.bg then
      ret.bg = default_color.bg
      if loaded_highlights[default_hl_name] then
        loaded_highlights[default_hl_name].attached[hl_name] = { bg = 'bg' }
      end
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
---@return table that can be used by component_format_highlight
---  to retrieve highlight group
function M.create_component_highlight_group(color, highlight_tag, options, apply_no_default)
  local tag_id = 0
  -- convert lualine_a -> a before setting section
  local section = options.self.section:match('lualine_(.*)')
  if section > 'c' and not active_theme.normal[section] then
    section = section_highlight_map[section]
  end
  while
    M.highlight_exists(table.concat({ 'lualine', highlight_tag }, '_'))
    or (
      options.self.section
      and M.highlight_exists(table.concat({ options.self.section, highlight_tag, 'normal' }, '_'))
    )
  do
    highlight_tag = highlight_tag .. '_' .. tostring(tag_id)
    tag_id = tag_id + 1
  end
  if type(color) == 'string' then
    local highlight_group_name = table.concat({ 'lualine', highlight_tag }, '_')
    M.highlight(highlight_group_name, nil, nil, nil, color) -- l8nk to group
    return { name = highlight_group_name, no_mode = true, link = true, no_default = apply_no_default, options = options}
  end
  if type(color) == 'function' then
    local highlight_group_name = table.concat({ 'lualine', highlight_tag }, '_')
    return {
      name = highlight_group_name,
      fn = color,
      no_mode = false,
      section = section,
      options = options,
      no_default = apply_no_default,
    }
  end
  if apply_no_default or (color.bg and color.fg) then
    -- When bg and fg are both present we donn't need to set highlighs for
    -- each mode as they will surely look the same. So we can work without options
    local highlight_group_name = table.concat({ 'lualine', highlight_tag }, '_')
    M.highlight(highlight_group_name, color.fg, color.bg, color.gui, nil)
    return { name = highlight_group_name, no_mode = true, section = section, no_default = apply_no_default }
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
    local cl = get_default_component_color(highlight_group_name, mode, section, color, options)
    M.highlight(table.concat(highlight_group_name, '_'), cl.fg, cl.bg, color.gui, nil)
  end
  return {
    name = options.self.section .. '_' .. highlight_tag,
    no_mode = false,
    section = section,
    options = options,
    no_default = apply_no_default,
  }
end

---@description: retrieve highlight_groups for components
---@param highlight string highlight group name without mode
---  return value of create_component_highlight_group is to be passed in
---  this parameter to receive highlight that was created
---@return string formatted highlight group name
function M.component_format_highlight(highlight, is_focused)
  if not highlight.fn then
    local highlight_group = highlight.name
    if highlight.no_mode then
      return '%#' .. highlight_group .. '#'
    end
    highlight_group = M.append_mode(highlight_group, is_focused)
    return '%#' .. highlight_group .. '#'
  else
    local mode = require('lualine.utils.mode').get_mode()
    local color = highlight.fn { mode = mode, section = highlight.section }
    if type(color) == 'string' then
      local hl_name = highlight.name
      M.highlight(hl_name, nil, nil, nil, color)
      return '%#' .. hl_name .. '#'
    elseif type(color) == 'table' then
      local hl_name = highlight.name
      if not highlight.no_default and not (color.fg and color.bg) then
        hl_name = M.append_mode(highlight.name, is_focused)
        color = get_default_component_color(hl_name, mode, highlight.section, color, highlight.options)
      end
      M.highlight(hl_name, color.fg, color.bg, color.gui, nil)
      return '%#' .. hl_name .. '#'
    end
  end
end

---@description: retrieve highlight_groups for section
---@param section string highlight group name without mode
---  return value of create_component_highlight_group is to be passed in
---  this parameter to receive highlight that was created
---@param is_focused boolean
---@return string formatted highlight group name
function M.format_highlight(section, is_focused)
  local mode
  if is_focused then
    mode = mode_to_highlight[require('lualine.utils.mode').get_mode()] or '_normal'
  else
    mode = '_inactive'
  end
  mode = mode:sub(2)
  if theme_hls[mode] and theme_hls[mode][section] then
    return M.component_format_highlight(theme_hls[mode][section], is_focused)
  elseif theme_hls[mode] and section > 'c' and theme_hls[mode][section_highlight_map[section]] then
    return M.component_format_highlight(theme_hls[mode][section_highlight_map[section]], is_focused)
  elseif theme_hls['normal'] and theme_hls['normal'][section] then
    return M.component_format_highlight(theme_hls['normal'][section], is_focused)
  elseif theme_hls['normal'] and section > 'c' and theme_hls['normal'][section_highlight_map[section]] then
    return M.component_format_highlight(theme_hls['normal'][section_highlight_map[section]], is_focused)
  else
    error('Unable to ditermine color for mode: ' .. mode .. ', section: ' .. section)
  end
  -- local highlight_name = M.append_mode(section, is_focused)
  -- if section > 'lualine_c' and not M.highlight_exists(highlight_name) then
  --   section = 'lualine_' .. section_highlight_map[section:match('lualine_(.)')]
  --   highlight_name = M.append_mode(section, is_focused)
  -- end
  -- if M.highlight_exists(highlight_name) then
  --   return '%#' .. highlight_name .. '#'
  -- end
  -- return '%#' .. section .. '_normal#'
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
    if loaded_highlights[left_hl] then
      loaded_highlights[left_hl].attached[highlight_name] = { bg = 'fg' }
    end
    if loaded_highlights[right_hl] then
      loaded_highlights[right_hl].attached[highlight_name] = { fg = 'bg' }
    end
  end
  return '%#' .. highlight_name .. '#'
end

return M
