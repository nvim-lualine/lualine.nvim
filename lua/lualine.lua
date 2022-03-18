-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require {
  highlight = 'lualine.highlight',
  loader = 'lualine.utils.loader',
  utils_section = 'lualine.utils.section',
  utils = 'lualine.utils.utils',
  utils_notices = 'lualine.utils.notices',
  config_module = 'lualine.config',
}
local config -- Stores currently applied config

-- Helper for apply_transitional_separators()
--- finds first applied highlight group fter str_checked in status
---@param status string : unprossed statusline string
---@param str_checked number : position of how far status has been checked
---@return string|nil the hl group name or nil
local function find_next_hl(status, str_checked)
  -- Gets the next valid hl group from str_checked
  local hl_pos_start, hl_pos_end = status:find('%%#.-#', str_checked)
  while true do
    if not hl_pos_start then
      return nil
    end
    -- When there are more that one hl group next to one another like
    -- %#HL1#%#HL2#%#HL3# we need to return HL3. This makes that happen.
    local next_start, next_end = status:find('^%%#.-#', hl_pos_end + 1)
    if next_start == nil then
      break
    end
    hl_pos_start, hl_pos_end = next_start, next_end
  end
  return status:sub(hl_pos_start + 2, hl_pos_end - 1)
end

-- Helper for apply_transitional_separators()
--- applies transitional separator highlight + transitional separator
---@param status string : unprossed statusline string
---@param str_checked number : position of how far status has been checked
---@param last_hl string : last applied hl group name before str_checked
---@param reverse boolean : reverse the hl group ( true for right separators )
---@return string|nil concated separator highlight and transitional separator
local function fill_section_separator(status, str_checked, last_hl, sep, reverse)
  -- Inserts transitional separator along with transitional highlight
  local next_hl = find_next_hl(status, str_checked)
  if last_hl == nil then
    last_hl = 'Normal'
  end
  if next_hl == nil then
    next_hl = 'Normal'
  end
  if #next_hl == 0 or #last_hl == 0 then
    return
  end
  local transitional_highlight = reverse -- lua ternary assignment x ? y : z
      and modules.highlight.get_transitional_highlights(last_hl, next_hl)
    or modules.highlight.get_transitional_highlights(next_hl, last_hl)
  if transitional_highlight then
    return transitional_highlight .. sep
  end
end

--- processes statusline string
--- replaces %s/S{sep} with proper left/right separator highlight + sep
---@param status string : unprossed statusline string
---@return string : processed statusline string
local function apply_transitional_separators(status)
  local status_applied = {} -- Collects all the pieces for concatation
  local last_hl -- Stores lash highligjt group that we found
  local last_hl_reseted = false -- Whether last_hl is nil because we reseted
  -- it after %=
  local copied_pos = 1 -- Tracks how much we've copied over to status_applied
  local str_checked = 1 -- Tracks where the searcher head is at

  -- Process entire status replace the %s{sep} & %S{sep} placeholders
  -- with proper transitional separator.
  while str_checked ~= nil do
    str_checked = status:find('%%', str_checked)
    if str_checked == nil then
      break
    end
    table.insert(status_applied, status:sub(copied_pos, str_checked - 1))
    -- -1 so we don't copy '%'
    copied_pos = str_checked
    local next_char = modules.utils.charAt(status, str_checked + 1)
    if next_char == '#' then
      -- %#hl_name# highlights
      last_hl = status:match('^%%#(.-)#', str_checked)
      str_checked = str_checked + #last_hl + 3
    elseif next_char == 's' then
      -- %s{sep} is marker for left separator and
      local sep = status:match('^%%s{(.-)}', str_checked)
      str_checked = str_checked + #sep + 4 -- 4 = len(%{})
      if not (last_hl == nil and last_hl_reseted) then
        local trans_sep = fill_section_separator(status, str_checked, last_hl, sep, false)
        if trans_sep then
          table.insert(status_applied, trans_sep)
        end
      end
      if last_hl_reseted then
        last_hl_reseted = false
      end
      copied_pos = str_checked
    elseif next_char == 'S' then
      -- %S{sep} is marker for right separator and
      local sep = status:match('^%%S{(.-)}', str_checked)
      str_checked = str_checked + #sep + 4 -- 4 = len(%{})
      if status:find('^%%s', str_checked) or status:find('^%%<%%s', str_checked) then
        -- When transitional right_sep and left_sep are right next to each other
        -- and in this exact order skip the left sep as we can't draw both.
        str_checked = status:find('}', str_checked) + 1
      end
      local trans_sep = fill_section_separator(status, str_checked, last_hl, sep, true)
      if trans_sep then
        table.insert(status_applied, trans_sep)
      end
      copied_pos = str_checked
    elseif next_char == '%' then
      str_checked = str_checked + 2 -- Skip the following % too
    elseif next_char == '=' and last_hl and (last_hl:find('^lualine_a') or last_hl:find('^lualine_b')) then
      -- TODO: Fix this properly
      -- This check for lualine_a and lualine_b is dumb. It doesn't garantee
      -- c or x section isn't present. Worst case sinario after this patch
      -- we have another visual bug that occurs less frequently.
      -- Annoying Edge Cases............................................
      last_hl = nil
      last_hl_reseted = true
      str_checked = str_checked + 1 -- Skip the following % too
    else
      str_checked = str_checked + 1 -- Push it forward to avoid inf loop
    end
  end
  table.insert(status_applied, status:sub(copied_pos)) -- Final chunk
  return table.concat(status_applied)
end

--- creates the statusline string
---@param sections table : section config where components are replaced with
---      component objects
---@param is_focused boolean : whether being evsluated for focused window or not
---@return string statusline string
local statusline = modules.utils.retry_call_wrap(function(sections, is_focused)
  -- The sequence sections should maintain [SECTION_SEQUENCE]
  local section_sequence = { 'a', 'b', 'c', 'x', 'y', 'z' }
  local status = {}
  local applied_midsection_divider = false
  local applied_trunc = false
  for _, section_name in ipairs(section_sequence) do
    if sections['lualine_' .. section_name] then
      -- insert highlight+components of this section to status_builder
      local section_data = modules.utils_section.draw_section(
        sections['lualine_' .. section_name],
        section_name,
        is_focused
      )
      if #section_data > 0 then
        if not applied_midsection_divider and section_name > 'c' then
          applied_midsection_divider = true
          section_data = modules.highlight.format_highlight('c', is_focused) .. '%=' .. section_data
        end
        if not applied_trunc and section_name > 'b' then
          applied_trunc = true
          section_data = '%<' .. section_data
        end
        table.insert(status, section_data)
      end
    end
  end
  if applied_midsection_divider == false and config.options.always_divide_middle ~= false then
    -- When non of section x,y,z is present
    table.insert(status, modules.highlight.format_highlight('c', is_focused) .. '%=')
  end
  return apply_transitional_separators(table.concat(status))
end)

--- check if any extension matches the filetype and return proper sections
---@param current_ft string : filetype name of current file
---@param is_focused boolean : whether being evsluated for focused window or not
---@return table : (section_table) section config where components are replaced with
---      component objects
-- TODO: change this so it uses a hash table instead of iteration over lisr
--       to improve redraws. Add buftype / bufname for extensions
--       or some kind of cond ?
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

---@return string statusline string for tabline
local function tabline()
  return statusline(config.tabline, true)
end

local function notify_theme_error(theme_name)
  local message_template = theme_name ~= 'auto'
      and [[
### options.theme
Theme `%s` not found, falling back to `auto`. Check if spelling is right.
]]
    or [[
### options.theme
Theme `%s` failed, falling back to `gruvbox`.
This shouldn't happen.
Please report the issue at https://github.com/nvim-lualine/lualine.nvim/issues .
Also provide what colorscheme you're using.
]]
  modules.utils_notices.add_notice(string.format(message_template, theme_name))
end

--- sets up theme by defining hl groups and setting theme cache in highlight.lua
--- uses options.theme option for theme if it's a string loads theme of that name
--- if it's a table directlybuses it .
--- when theme load fails this fallsback to 'auto' theme if even that fails
--- this falls back to 'gruvbox' theme
--- also sets up auto command to reload lualine on ColorScheme or background
---  change on
local function setup_theme()
  local function get_theme_from_config()
    local theme_name = config.options.theme
    if type(theme_name) == 'string' then
      local ok, theme = pcall(modules.loader.load_theme, theme_name)
      if ok and theme then
        return theme
      end
    elseif type(theme_name) == 'table' then
      -- use the provided theme as-is
      return config.options.theme
    end
    if theme_name ~= 'auto' then
      notify_theme_error(theme_name)
      local ok, theme = pcall(modules.loader.load_theme, 'auto')
      if ok and theme then
        return theme
      end
    end
    notify_theme_error('auto')
    return modules.loader.load_theme('gruvbox')
  end
  local theme = get_theme_from_config()
  modules.highlight.create_highlight_groups(theme)
  vim.cmd([[autocmd lualine ColorScheme * lua require'lualine'.setup()
    autocmd lualine OptionSet background lua require'lualine'.setup()]])
end

--- Sets &tabline option to lualine
local function set_tabline()
  if next(config.tabline) ~= nil then
    vim.go.tabline = "%{%v:lua.require'lualine'.tabline()%}"
    vim.go.showtabline = 2
  elseif vim.go.tabline == "%{%v:lua.require'lualine'.tabline()%}" then
    vim.go.tabline = nil
    vim.go.showtabline = 1
  end
end

--- Sets &ststusline option to lualine
--- adds auto command to redraw lualine on VimResized event
local function set_statusline()
  if next(config.sections) ~= nil or next(config.inactive_sections) ~= nil then
    vim.cmd('autocmd lualine VimResized * redrawstatus')
    vim.go.statusline = "%{%v:lua.require'lualine'.statusline()%}"
    vim.go.laststatus = config.options.globalstatus and 3 or 2
  elseif vim.go.statusline == "%{%v:lua.require'lualine'.statusline()%}" then
    vim.go.statusline = nil
    vim.go.laststatus = 2
  end
end

-- lualine.statusline function
--- Draw correct statusline for current winwow
---@param focused boolean : force the vale of is_focuased . useful for debugginf
---@return string statusline string
local function status_dispatch(focused)
  local retval
  local current_ft = vim.bo.filetype
  local is_focused = focused ~= nil and focused or modules.utils.is_focused()
  for _, ft in pairs(config.options.disabled_filetypes) do
    -- disable on specific filetypes
    if ft == current_ft then
      return ''
    end
  end
  local extension_sections = get_extension_sections(current_ft, is_focused)
  if is_focused then
    if extension_sections ~= nil then
      retval = statusline(extension_sections, is_focused)
    else
      retval = statusline(config.sections, is_focused)
    end
  else
    if extension_sections ~= nil then
      retval = statusline(extension_sections, is_focused)
    else
      retval = statusline(config.inactive_sections, is_focused)
    end
  end
  return retval
end

-- lualine.setup function
--- sets new user config
--- This function doesn't load components/theme etc.. they are done before
--- first statusline redraw after new config. This is more efficient when
--- lualine config is done in several setup calls in chunks. This way
--- we don't intialize components just to throgh them away .Instead they are
--- initialized when we know we will use them.
--- sets &last_status tl 2
---@param user_config table table
local function setup(user_config)
  if package.loaded['lualine.utils.notices'] then
    -- When notices module is not loaded there are no notices to clear.
    modules.utils_notices.clear_notices()
  end
  config = modules.config_module.apply_configuration(user_config)
  vim.cmd([[augroup lualine | exe "autocmd!" | augroup END]])
  setup_theme()
  -- load components & extensions
  modules.loader.load_all(config)
  set_statusline()
  set_tabline()
  if package.loaded['lualine.utils.notices'] then
    modules.utils_notices.notice_message_startup()
  end
end

return {
  setup = setup,
  statusline = status_dispatch,
  tabline = tabline,
  get_config = modules.config_module.get_config,
}
