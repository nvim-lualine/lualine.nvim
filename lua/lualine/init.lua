-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local highlight = require('lualine.highlight')
local loader = require('lualine.utils.loader')
local utils_section = require('lualine.utils.section')
local utils = require('lualine.utils.utils')
local config_module = require('lualine.config')

local config = config_module.config

local function apply_transitional_separators(previous_section, current_section,
                                             next_section)

  local function fill_section_separator(prev, next, sep, reverse)
    if #sep == 0 then return 0 end
    local transitional_highlight = highlight.get_transitional_highlights(prev,
                                                                         next,
                                                                         reverse)
    if transitional_highlight and #transitional_highlight > 0 then
      return transitional_highlight .. sep
    else
      return ''
    end
  end

  -- variable to track separators position
  local sep_pos = 1

  -- %s{sep} is marker for left separator and
  -- %S{sep} is marker for right separator
  -- Apply left separator
  while sep_pos do
    -- get what the separator char
    local sep = current_section.data:match('%%s{(.-)}', sep_pos)
    -- Get where separator starts from
    sep_pos = current_section.data:find('%%s{.-}', sep_pos)
    if not sep or not sep_pos then break end
    -- part of section before separator . -1 since we don't want the %
    local prev = current_section.data:sub(1, sep_pos - 1)
    -- part of section after separator. 4 is length of "%s{}"
    local nxt = current_section.data:sub(sep_pos + 4 + #sep)
    -- prev might not exist when separator is the first element of section
    -- use previous section as prev
    if not prev or #prev == 0 or sep_pos == 1 then
      prev = previous_section.data
    end
    if prev ~= previous_section.data then
      -- Since the section isn't suppose to be highlighted with separators
      -- separators highlight extract the last highlight and place it between
      -- separator and section
      local last_hl = prev:match('.*(%%#.-#).-')
      current_section.data = prev ..
                                 fill_section_separator(prev, nxt, sep, false) ..
                                 last_hl .. nxt
    else
      current_section.data = fill_section_separator(prev, nxt, sep, true) .. nxt
    end
  end

  -- Reset pos for right separator
  sep_pos = 1
  -- Apply right separator
  while sep_pos do
    local sep = current_section.data:match('%%S{(.-)}', sep_pos)
    sep_pos = current_section.data:find('%%S{.-}', sep_pos)
    if not sep or not sep_pos then break end
    local prev = current_section.data:sub(1, sep_pos - 1)
    local nxt = current_section.data:sub(sep_pos + 4 + #sep)
    if not nxt or #nxt == 0 or sep_pos == #current_section.data then
      nxt = next_section.data
    end
    if nxt ~= next_section.data then
      current_section.data = prev ..
                                 fill_section_separator(prev, nxt, sep, false) ..
                                 nxt
    else
      current_section.data = prev ..
                                 fill_section_separator(prev, nxt, sep, false)
    end
    sep_pos = sep_pos + 4 + #sep
  end
  return current_section.data
end

local function statusline(sections, is_focused)

  -- status_builder stores statusline without section_separators
  -- The sequence sections should maintain
  local section_sequence = {'a', 'b', 'c', 'x', 'y', 'z'}
  local status_builder = {}
  for _, section_name in ipairs(section_sequence) do
    if sections['lualine_' .. section_name] then
      -- insert highlight+components of this section to status_builder
      local section_data = utils_section.draw_section(
                               sections['lualine_' .. section_name],
                               section_name, is_focused)
      if #section_data > 0 then
        table.insert(status_builder, {name = section_name, data = section_data})
      end
    end
  end

  -- Actual statusline
  local status = {}
  local half_passed = false
  for i = 1, #status_builder do
    -- midsection divider
    if not half_passed and status_builder[i].name > 'c' then
      table.insert(status,
                   highlight.format_highlight(is_focused, 'lualine_c') .. '%=')
      half_passed = true
    end
    -- component separator needs to have fg = current_section.bg
    -- and bg = adjacent_section.bg
    local previous_section = status_builder[i - 1] or {}
    local current_section = status_builder[i]
    local next_section = status_builder[i + 1] or {}

    local section = apply_transitional_separators(previous_section,
                                                  current_section, next_section)

    table.insert(status, section)
  end
  -- incase none of x,y,z was configured lets not fill whole statusline with a,b,c section
  if not half_passed then
    table.insert(status,
                 highlight.format_highlight(is_focused, 'lualine_c') .. '%=')
  end
  return table.concat(status)
end

-- check if any extension matches the filetype and return proper sections
local function get_extension_sections(current_ft, is_focused)
  for _, extension in ipairs(config.extensions) do
    for _, filetype in ipairs(extension.filetypes) do
      if current_ft == filetype then
        if is_focused == false and extension.inactive_sections then
          return extension.inactive_sections
        end
        return extension.sections
      end
    end
  end
  return nil
end

local function status_dispatch()
  -- disable on specific filetypes
  local current_ft = vim.bo.filetype
  local is_focused = utils.is_focused()
  for _, ft in pairs(config.options.disabled_filetypes) do
    if ft == current_ft then
      vim.wo.statusline = ''
      return ''
    end
  end
  local extension_sections = get_extension_sections(current_ft, is_focused)
  if is_focused then
    if extension_sections ~= nil then
      return statusline(extension_sections, is_focused)
    end
    return statusline(config.sections, is_focused)
  else
    if extension_sections ~= nil then
      return statusline(extension_sections, is_focused)
    end
    return statusline(config.inactive_sections, is_focused)
  end
end

local function tabline() return statusline(config.tabline, true) end

local function setup_theme()
  local function get_theme_from_config()
    local theme_name = config.options.theme
    if type(theme_name) == 'string' then
      package.loaded['lualine.themes.'..theme_name] = nil
      local ok, theme = pcall(require, 'lualine.themes.' .. theme_name)
      if ok then return theme end
    elseif type(theme_name) == 'table' then
      -- use the provided theme as-is
      return config.options.theme
    end
    vim.api.nvim_err_writeln('theme ' .. tostring(theme_name) ..
                                 ' not found, defaulting to gruvbox')
    return require 'lualine.themes.gruvbox'
  end
  local theme = get_theme_from_config()
  highlight.create_highlight_groups(theme)
  vim.cmd [[
    autocmd lualine ColorScheme * lua require'lualine.utils.utils'.reload_highlights()
    autocmd lualine OptionSet background lua require'lualine'.setup()
  ]]
end

local function set_tabline()
  if next(config.tabline) ~= nil then
    vim.go.tabline = "%{%v:lua.require'lualine'.tabline()%}"
    vim.go.showtabline = 2
  end
end

local function set_statusline()
  if next(config.sections) ~= nil or next(config.inactive_sections) ~= nil then
    vim.go.statusline = "%{%v:lua.require'lualine'.statusline()%}"
    vim.cmd([[
      autocmd lualine VimResized * redrawstatus
    ]])
  end
end

local function setup_augroup()
  vim.cmd [[
    augroup lualine
      autocmd!
    augroup END
  ]]
end

local function setup(user_config)
  config = config_module.apply_configuration(user_config)
  setup_augroup()
  setup_theme()
  loader.load_all(config)
  set_statusline()
  set_tabline()
end

return {
  setup = setup,
  statusline = status_dispatch,
  tabline = tabline,
  get_config = config_module.get_config,
}
