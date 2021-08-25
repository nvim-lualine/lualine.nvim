-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local modules = require('lualine.utils.lazy_require'){
  highlight = 'lualine.highlight',
  loader = 'lualine.utils.loader',
  utils_section = 'lualine.utils.section',
  utils = 'lualine.utils.utils',
  utils_notices = 'lualine.utils.notices',
  config_module = 'lualine.config',
  nt = 'lualine.utils.native',
}
local config           -- Stores cureently applied config
local new_config = true  -- Stores config that will be applied

local function apply_transitional_separators(previous_section, current_section,
                                             next_section)

  local function fill_section_separator(prev, next, sep, reverse)
    if #sep == 0 then return 0 end
    local transitional_highlight = modules.highlight.get_transitional_highlights(prev,
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
    local sep = current_section:match('%%s{(.-)}', sep_pos)
    -- Get where separator starts from
    sep_pos = current_section:find('%%s{.-}', sep_pos)
    if not sep or not sep_pos then break end
    -- part of section before separator . -1 since we don't want the %
    local prev = current_section:sub(1, sep_pos - 1)
    -- part of section after separator. 4 is length of "%s{}"
    local nxt = current_section:sub(sep_pos + 4 + #sep)
    -- prev might not exist when separator is the first element of section
    -- use previous section as prev
    if not prev or #prev == 0 or sep_pos == 1 then
      prev = previous_section
    end
    if prev ~= previous_section then
      -- Since the section isn't suppose to be highlighted with separators
      -- separators highlight extract the last highlight and place it between
      -- separator and section
      local last_hl = prev:match('.*(%%#.-#).-')
      current_section = prev ..
                                 fill_section_separator(prev, nxt, sep, false) ..
                                 last_hl .. nxt
    else
      current_section = fill_section_separator(prev, nxt, sep, true) .. nxt
    end
  end

  -- Reset pos for right separator
  sep_pos = 1
  -- Apply right separator
  while sep_pos do
    local sep = current_section:match('%%S{(.-)}', sep_pos)
    sep_pos = current_section:find('%%S{.-}', sep_pos)
    if not sep or not sep_pos then break end
    local prev = current_section:sub(1, sep_pos - 1)
    local nxt = current_section:sub(sep_pos + 4 + #sep)
    if not nxt or #nxt == 0 or sep_pos == #current_section then
      nxt = next_section
    end
    if nxt ~= next_section then
      current_section = prev ..
                                 fill_section_separator(prev, nxt, sep, false) ..
                                 nxt
    else
      current_section = prev ..
                                 fill_section_separator(prev, nxt, sep, false)
    end
    sep_pos = sep_pos + 4 + #sep
  end
  return current_section
end

local function statusline(sections, is_focused)

  -- status_builder stores statusline without section_separators
  -- The sequence sections should maintain
  local section_sequence = {'a', 'b', 'c', 'x', 'y', 'z'}
  local status_builder = {}
  local applied_mid_sep = false
  for _, section_name in ipairs(section_sequence) do
    if sections['lualine_' .. section_name] then
      -- insert highlight+components of this section to status_builder
      local section_data = modules.utils_section.draw_section(
                               sections['lualine_' .. section_name],
                               section_name, is_focused)
      if #section_data > 0 then
        if section_name > 'c' and not applied_mid_sep then
          applied_mid_sep = true
          section_data = '%='..section_data
        end
        -- table.insert(status_builder, {name = section_name, data = section_data})
        table.insert(status_builder, section_data)
      end
    end
  end
  -- Actual statusline
  if (modules.nt) then
    local status = table.concat(status_builder)
    return modules.nt.apply_ts_sep_native(status)
  else
    local status = {}
    for i = 1, #status_builder do
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
    return table.concat(status)
  end
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

local function tabline() return statusline(config.tabline, true) end

local function check_theme_name_deprecation(theme_name)
  local deprection_table = {
    oceanicnext      = 'OceanicNext',
    papercolor       = 'PaperColor',
    tomorrow         = 'Tomorrow',
    gruvbox_material = 'gruvbox-material',
    modus_vivendi    = 'modus-vivendi',
  }
  if deprection_table[theme_name] then
    local correct_name = deprection_table[theme_name]
    modules.utils_notices.add_notice(string.format([[
### options.theme
You're using `%s` as theme name .
It has recently been renamed to `%s`.
Please update your config to follow that.

You have something like this in your config.
```lua
options = {
  theme = '%s'
}
```

You'll have to change it to something like this.
```lua
options = {
  theme = '%s'
}
```

]], theme_name, correct_name, theme_name, correct_name))
    return  correct_name
  end
  return theme_name
end

local function notify_theme_error(theme_name)
  local message_template = theme_name ~= 'auto' and [[
### options.theme
Theme `%s` not found, falling back to `auto`. Check if spelling is right.
]] or [[
### options.theme
Theme `%s` failed, falling back to `gruvbox`.
This shouldn't happen.
Please report the issue at https://github.com/shadmansaleh/lualine.nvim/issues .
Also provide what colorscheme you're using.
]]
  modules.utils_notices.add_notice(string.format(message_template, theme_name))
end

local function setup_theme()
  local function get_theme_from_config()
    local theme_name = config.options.theme
    if type(theme_name) == 'string' then
      theme_name = check_theme_name_deprecation(theme_name)
      local ok, theme = pcall(modules.loader.load_theme, theme_name)
      if ok and theme then return theme end
    elseif type(theme_name) == 'table' then
      -- use the provided theme as-is
      return config.options.theme
    end
    if theme_name ~= 'auto' then
      notify_theme_error(theme_name)
      local ok, theme = pcall(modules.loader.load_theme, 'auto')
      if ok and theme then return theme end
    end
    notify_theme_error('auto')
    return modules.loader.load_theme('gruvbox')
  end
  local theme = get_theme_from_config()
  modules.highlight.create_highlight_groups(theme)
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
    vim.cmd('autocmd lualine VimResized * redrawstatus')
  else
    vim.go.statusline = nil
  end
end

local function setup_augroup()
  vim.cmd [[
    augroup lualine
      autocmd!
    augroup END
  ]]
end

local function reset_lualine()
  modules.utils_notices.clear_notices()
  setup_augroup()
  setup_theme()
  modules.loader.load_all(config)
  set_statusline()
  set_tabline()
  modules.utils_notices.notice_message_startup()
  new_config = nil
end

local function status_dispatch(focused)
  -- disable on specific filetypes
  if new_config then reset_lualine() end
  local current_ft = vim.bo.filetype
  local is_focused = focused ~= nil and focused or modules.utils.is_focused()
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

local function setup(user_config)
  new_config = true
  config = modules.config_module.apply_configuration(user_config)
  vim.go.statusline = "%{%v:lua.require'lualine'.statusline()%}"
end

return {
  setup = setup,
  statusline = status_dispatch,
  tabline = tabline,
  get_config = modules.config_module.get_config,
}
