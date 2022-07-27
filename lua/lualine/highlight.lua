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
  if color == nil or color == '' or (type(color) == 'string' and color:lower() == 'none') then
    return 'None'
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

function M.get_lualine_hl(name)
  local hl = loaded_highlights[name]
  if hl and not hl.empty then
    if hl.link then
      return modules.utils.extract_highlight_colors(hl.link)
    end
    local hl_def = {
      fg = hl.fg ~= 'None' and vim.deepcopy(hl.fg) or nil,
      bg = hl.bg ~= 'None' and vim.deepcopy(hl.bg) or nil,
    }
    if hl.gui then
      for _, flag in ipairs(vim.split(hl.gui, ',')) do
        if flag ~= 'None' then
          hl_def[flag] = true
        end
      end
    end

    return hl_def
  end
end

--- Define a hl_group
---@param name string
---@param foreground string|number: color
---@param background string|number: color
---@param gui table cterm/gui options like bold/italic etc.
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
    gui = (gui ~= nil and gui ~= '') and gui or 'None'
    if
      loaded_highlights[name]
      and loaded_highlights[name].fg == foreground
      and loaded_highlights[name].bg == background
      and loaded_highlights[name].gui == gui
    then
      return -- color is already defined why are we doing this anyway ?
    end
    table.insert(command, name)
    table.insert(command, 'guifg=' .. foreground)
    table.insert(command, 'guibg=' .. background)
    table.insert(command, 'gui=' .. gui)
    if create_cterm_colors then
      table.insert(command, 'ctermfg=' .. modules.color_utils.rgb2cterm(foreground))
      table.insert(command, 'ctermbg=' .. modules.color_utils.rgb2cterm(background))
      table.insert(command, 'cterm=' .. gui)
    end
  end
  vim.cmd(table.concat(command, ' '))

  -- update attached hl groups
  local old_hl_def = loaded_highlights[name]
  if old_hl_def and next(old_hl_def.attached) then
    -- Update attached hl groups as they announced to depend on hl_group 'name'
    -- 'hl' being in 'name's attached table means 'hl'
    -- depends of 'name'.
    -- 'hl' key in attached table will contain a table that
    -- defines the relation between 'hl' & 'name'.
    -- name.attached.hl = { bg = 'fg' } means
    -- hl's fg is same as 'names' bg . So 'hl's fg should
    -- be updated when ever 'name' changes it's 'bg'
    local bg_changed = old_hl_def.bg ~= background
    local fg_changed = old_hl_def.bg ~= foreground
    local gui_changed = old_hl_def.gui ~= gui
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
      if gui_changed and attach_desc.gui and loaded_highlights[attach_name] then
        M.highlight(
          attach_name,
          loaded_highlights[attach_name].fg,
          loaded_highlights[attach_name].bg,
          gui,
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

---Attach a hl to another, so the attachee auto updates on change to hl that it's attached too.
---@param provider string the hl receiver is getting attached to
---@param receiver string the hl that will be auto updated upon change to provider
---@param provider_el_type string (fg/bg) what element receiver relates to of provider
---@param receiver_el_type string (fg/bg) what element provider relates to of receiver
local function attach_hl(provider, receiver, provider_el_type, receiver_el_type)
  if loaded_highlights[provider] == nil then
    loaded_highlights[provider] = { empty = true, attached = {} }
  end
  loaded_highlights[provider].attached[receiver] = { [provider_el_type] = receiver_el_type }
end
---define hl_groups for a theme
---@param theme table
function M.create_highlight_groups(theme)
  clear_highlights()
  active_theme = theme
  theme_hls = {}
  local psudo_options = { self = { section = 'a' } }
  create_cterm_colors = not vim.go.termguicolors
  for mode, sections in pairs(theme) do
    theme_hls[mode] = {}
    for section, color in pairs(sections) do
      local hl_tag = mode
      psudo_options.self.section = section
      theme_hls[mode][section] = M.create_component_highlight_group(color, hl_tag, psudo_options, true)
    end
  end
end

---@description: adds '_mode' at end of highlight_group
---@param highlight_group string name of highlight group
---@return string highlight group name with mode
local function append_mode(highlight_group, is_focused)
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
---@param hl_name string name of highlight that we are setting default values for
---@param mode string mode which default component color should be given.
---@param section string the lualine section component is in.
---@param color table color passed for creating component highlight
---@param options table Options table of component this is first fall back
local function get_default_component_color(hl_name, mode, section, color, options)
  local default_theme_color
  if active_theme[mode] and active_theme[mode][section] then
    default_theme_color = active_theme[mode][section]
  elseif section >= 'c' and active_theme[mode] and active_theme[mode][section_highlight_map[section]] then
    default_theme_color = active_theme[mode][section_highlight_map[section]]
  elseif section >= 'c' and active_theme.normal[section_highlight_map[section]] then
    default_theme_color = active_theme.normal[section_highlight_map[section]]
  else
    default_theme_color = active_theme.normal[section]
  end

  local ret = { fg = color.fg, bg = color.bg, gui = color.gui }
  if ret.fg and ret.bg then
    return ret
  end

  local function apply_default(def_color, def_name)
    if type(def_color) == 'function' and loaded_highlights[def_name] and not loaded_highlights[def_name].empty then
      if loaded_highlights[def_name].link then
        def_color = loaded_highlights[def_name].link
      else
        def_color = loaded_highlights[def_name]
      end
    end
    if type(def_color) == 'function' then
      def_color = def_color { section = section }
    end
    if type(def_color) == 'string' then
      def_color = modules.utils.extract_highlight_colors(def_color)
    end
    if type(def_color) == 'table' then
      if not ret.fg then
        ret.fg = def_color.fg
        attach_hl(def_name, hl_name, 'fg', 'fg')
      end
      if not ret.bg then
        ret.bg = def_color.bg
        attach_hl(def_name, hl_name, 'bg', 'bg')
      end
    end
  end

  if
    options.color
    and options.color_highlight
    and options.color_highlight.name
    and options.color_highlight.name .. '_' .. mode ~= hl_name
  then
    apply_default(options.color, options.color_highlight.name .. '_' .. mode)
  end

  if not ret.fg or not ret.bg then
    apply_default(default_theme_color, string.format('lualine_%s_%s', section, mode))
  end
  ret.fg = sanitize_color(ret.fg)
  ret.bg = sanitize_color(ret.bg)
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
  local section = options.self.section
  local tag_id = 0
  while
    M.highlight_exists(table.concat({ 'lualine', section, highlight_tag }, '_'))
    or (section and M.highlight_exists(table.concat({ 'lualine', section, highlight_tag, 'normal' }, '_')))
  do
    highlight_tag = highlight_tag .. '_' .. tostring(tag_id)
    tag_id = tag_id + 1
  end

  if type(color) == 'string' then
    local highlight_group_name = table.concat({ 'lualine', section, highlight_tag }, '_')
    M.highlight(highlight_group_name, nil, nil, nil, color) -- l8nk to group
    return {
      name = highlight_group_name,
      fn = nil,
      no_mode = true,
      link = true,
      section = section,
      options = options,
      no_default = apply_no_default,
    }
  end

  if type(color) ~= 'function' and (apply_no_default or (color.bg and color.fg)) then
    -- When bg and fg are both present we donn't need to set highlighs for
    -- each mode as they will surely look the same. So we can work without options
    local highlight_group_name = table.concat({ 'lualine', section, highlight_tag }, '_')
    M.highlight(highlight_group_name, color.fg, color.bg, color.gui, nil)
    return {
      name = highlight_group_name,
      fn = nil,
      no_mode = true,
      section = section,
      options = options,
      no_default = apply_no_default,
    }
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
    local hl_name = table.concat({ 'lualine', section, highlight_tag, mode }, '_')
    local cl = color
    if type(color) == 'function' then
      cl = color { section = section } or {}
    end
    if type(cl) == 'string' then
      cl = { link = cl }
    else
      cl = get_default_component_color(hl_name, mode, section, cl, options)
    end
    M.highlight(hl_name, cl.fg, cl.bg, cl.gui, cl.link)
  end
  return {
    name = table.concat({ 'lualine', section, highlight_tag }, '_'),
    fn = type(color) == 'function' and color,
    no_mode = false,
    link = false,
    section = section,
    options = options,
    no_default = apply_no_default,
  }
end

---@description: retrieve highlight_groups for components
---@param highlight table return value of create_component_highlight_group
---  return value of create_component_highlight_group is to be passed in
---  this parameter to receive highlight that was created
---@return string formatted highlight group name
function M.component_format_highlight(highlight, is_focused)
  if not highlight.fn then
    local highlight_group = highlight.name
    if highlight.no_mode then
      return '%#' .. highlight_group .. '#'
    end
    highlight_group = append_mode(highlight_group, is_focused)
    return '%#' .. highlight_group .. '#'
  else
    local color = highlight.fn { section = highlight.section } or {}
    local hl_name = highlight.name
    if type(color) == 'string' then
      M.highlight(hl_name, nil, nil, nil, color)
      return '%#' .. hl_name .. '#'
    elseif type(color) == 'table' then
      if not highlight.no_default and not (color.fg and color.bg) then
        hl_name = append_mode(highlight.name, is_focused)
        color =
          get_default_component_color(hl_name, append_mode(''):sub(2), highlight.section, color, highlight.options)
      end
      M.highlight(hl_name, color.fg, color.bg, color.gui, color.link)
      return '%#' .. hl_name .. '#', color
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
  local mode = append_mode('', is_focused):sub(2)
  local ret = ''

  if theme_hls[mode] and theme_hls[mode][section] then
    ret = M.component_format_highlight(theme_hls[mode][section], is_focused)
  elseif theme_hls[mode] and section > 'c' and theme_hls[mode][section_highlight_map[section]] then
    ret = M.component_format_highlight(theme_hls[mode][section_highlight_map[section]], is_focused)
  elseif theme_hls['normal'] and theme_hls['normal'][section] then
    ret = M.component_format_highlight(theme_hls['normal'][section], is_focused)
  elseif theme_hls['normal'] and section > 'c' and theme_hls['normal'][section_highlight_map[section]] then
    ret = M.component_format_highlight(theme_hls['normal'][section_highlight_map[section]], is_focused)
  end

  return ret
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
    M.highlight(highlight_name, fg, bg, nil, nil)
    attach_hl(left_hl, highlight_name, 'bg', 'fg')
    attach_hl(right_hl, highlight_name, 'bg', 'bg')
  end
  return '%#' .. highlight_name .. '#'
end

function M.get_stl_default_hl(focused)
  if focused == 3 then
    return 'TabLineFill'
  elseif not focused then
    return 'StatusLineNC'
  else
    return 'StatusLine'
  end
end

return M
