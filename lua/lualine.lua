-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local M = {}

local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require {
  highlight = 'lualine.highlight',
  loader = 'lualine.utils.loader',
  utils_section = 'lualine.utils.section',
  utils = 'lualine.utils.utils',
  utils_notices = 'lualine.utils.notices',
  config_module = 'lualine.config',
  nvim_opts = 'lualine.utils.nvim_opts',
}
local config -- Stores currently applied config
local timers = {
  stl_timer = vim.loop.new_timer(),
  tal_timer = vim.loop.new_timer(),
  wb_timer = vim.loop.new_timer(),
}

-- The events on which lualine redraws itself
local default_refresh_events = 'WinEnter,BufEnter,SessionLoadPost,FileChangedShellPost,VimResized,Filetype'
if vim.fn.has('nvim-0.7') == 1 then -- utilize ModeChanged event introduced in 0.7
  default_refresh_events = default_refresh_events .. ',ModeChanged'
end
-- Helper for apply_transitional_separators()
--- finds first applied highlight group after str_checked in status
---@param status string : unprocessed statusline string
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
---@param status string : unprocessed statusline string
---@param str_checked number : position of how far status has been checked
---@param last_hl string : last applied hl group name before str_checked
---@param reverse boolean : reverse the hl group ( true for right separators )
---@return string|nil concatenate separator highlight and transitional separator
local function fill_section_separator(status, is_focused, str_checked, last_hl, sep, reverse)
  -- Inserts transitional separator along with transitional highlight
  local next_hl = find_next_hl(status, str_checked)
  if last_hl == nil then
    last_hl = modules.highlight.get_stl_default_hl(is_focused)
  end
  if next_hl == nil then
    next_hl = modules.highlight.get_stl_default_hl(is_focused)
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
---@param status string : unprocessed statusline string
---@return string : processed statusline string
local function apply_transitional_separators(status, is_focused)
  local status_applied = {} -- Collects all the pieces for concatenation
  local last_hl -- Stores last highlight group that we found
  local last_hl_reseted = false -- Whether last_hl is nil after reset
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
        local trans_sep = fill_section_separator(status, is_focused, str_checked, last_hl, sep, false)
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
      local trans_sep = fill_section_separator(status, is_focused, str_checked, last_hl, sep, true)
      if trans_sep then
        table.insert(status_applied, trans_sep)
      end
      copied_pos = str_checked
    elseif next_char == '%' then
      str_checked = str_checked + 2 -- Skip the following % too
    elseif next_char == '=' and last_hl and (last_hl:find('^lualine_a') or last_hl:find('^lualine_b')) then
      -- TODO: Fix this properly
      -- This check for lualine_a and lualine_b is dumb. It doesn't guarantee
      -- c or x section isn't present. Worst case scenario after this patch
      -- we have another visual bug that occurs less frequently.
      -- Annoying Edge Cases
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
---@param is_focused boolean : whether being evaluated for focused window or not
---@return string statusline string
local statusline = modules.utils.retry_call_wrap(function(sections, is_focused, is_winbar)
  -- The sequence sections should maintain [SECTION_SEQUENCE]
  local section_sequence = { 'a', 'b', 'c', 'x', 'y', 'z' }
  local status = {}
  local applied_midsection_divider = false
  local applied_trunc = false
  for _, section_name in ipairs(section_sequence) do
    if sections['lualine_' .. section_name] then
      -- insert highlight+components of this section to status_builder
      local section_data =
        modules.utils_section.draw_section(sections['lualine_' .. section_name], section_name, is_focused)
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
  if applied_midsection_divider == false and config.options.always_divide_middle ~= false and not is_winbar then
    -- When non of section x,y,z is present
    table.insert(status, modules.highlight.format_highlight('c', is_focused) .. '%=')
  end
  return apply_transitional_separators(table.concat(status), is_focused)
end)

--- check if any extension matches the filetype and return proper sections
---@param current_ft string : filetype name of current file
---@param is_focused boolean : whether being evaluated for focused window or not
---@return table : (section_table) section config where components are replaced with
---      component objects
-- TODO: change this so it uses a hash table instead of iteration over list
--       to improve redraws. Add buftype / bufname for extensions
--       or some kind of cond ?
local function get_extension_sections(current_ft, is_focused, sec_name)
  for _, extension in ipairs(config.extensions) do
    if vim.tbl_contains(extension.filetypes, current_ft) then
      return extension[(is_focused and '' or 'inactive_') .. sec_name]
    end
  end
  return nil
end

---@return string statusline string for tabline
local function tabline()
  return statusline(config.tabline, 3)
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

--- Sets up theme by defining hl groups and setting theme cache in 'highlight.lua'.
--- Uses 'options.theme' variable to apply the theme:
--- - If the value is a string, it'll load a theme of that name.
--- - If it's a table, it's directly used as the theme.
--- If loading the theme fails, this falls back to 'auto' theme.
--- If the 'auto' theme also fails, this falls back to 'gruvbox' theme.
--- Also sets up auto command to reload lualine on ColorScheme or background changes.
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

---@alias StatusDispatchSecs
---| 'sections'
---| 'winbar'
--- generates lualine.statusline & lualine.winbar function
--- creates a closer that can draw sections of sec_name.
---@param sec_name StatusDispatchSecs
---@return function(focused:bool):string
local function status_dispatch(sec_name)
  return function(focused)
    local retval
    local current_ft = vim.bo.filetype
    local is_focused = focused ~= nil and focused or modules.utils.is_focused()
    if
      vim.tbl_contains(
        config.options.disabled_filetypes[(sec_name == 'sections' and 'statusline' or sec_name)],
        current_ft
      )
    then
      -- disable on specific filetypes
      return nil
    end
    local extension_sections = get_extension_sections(current_ft, is_focused, sec_name)
    if extension_sections ~= nil then
      retval = statusline(extension_sections, is_focused, sec_name == 'winbar')
    else
      retval = statusline(config[(is_focused and '' or 'inactive_') .. sec_name], is_focused, sec_name == 'winbar')
    end
    return retval
  end
end

---@alias LualineRefreshOptsKind
---| 'all'
---| 'tabpage'
---| 'window'
---@alias LualineRefreshOptsPlace
---| 'statusline'
---| 'tabline'
---| 'winbar'
---@class LualineRefreshOpts
---@field kind LualineRefreshOptsKind
---@field place LualineRefreshOptsPlace[]
---@field trigger 'autocmd'|'autocmd_redired|timer'|'unknown'
--- Refresh contents of lualine
---@param opts LualineRefreshOpts
local function refresh(opts)
  if opts == nil then
    opts = { kind = 'tabpage', place = { 'statusline', 'winbar', 'tabline' }, trigger = 'unknown' }
  end

  -- updating statusline in autocommands context seems to trigger 100 different bugs
  -- lets just defer it to a timer context and update there
  -- workaround for https://github.com/neovim/neovim/issues/15300
  -- workaround for https://github.com/neovim/neovim/issues/19464
  -- workaround for https://github.com/nvim-lualine/lualine.nvim/issues/753
  -- workaround for https://github.com/nvim-lualine/lualine.nvim/issues/751
  -- workaround for https://github.com/nvim-lualine/lualine.nvim/issues/755
  if opts.trigger == 'autocmd' then
    opts.trigger = 'autocmd_redired'
    vim.defer_fn(function()
      M.refresh(opts)
    end, 50)
    return
  end

  local wins = {}
  local old_actual_curwin = vim.g.actual_curwin
  vim.g.actual_curwin = vim.api.nvim_get_current_win()
  -- gather which windows needs update
  if opts.kind == 'all' then
    if vim.tbl_contains(opts.place, 'statusline') or vim.tbl_contains(opts.place, 'winbar') then
      wins = vim.tbl_filter(function(win)
        return vim.fn.win_gettype(win) ~= 'popup'
      end, vim.api.nvim_list_wins())
    end
  elseif opts.kind == 'tabpage' then
    if vim.tbl_contains(opts.place, 'statusline') or vim.tbl_contains(opts.place, 'winbar') then
      wins = vim.tbl_filter(function(win)
        return vim.fn.win_gettype(win) ~= 'popup'
      end, vim.api.nvim_tabpage_list_wins(0))
    end
  elseif opts.kind == 'window' then
    wins = { vim.api.nvim_get_current_win() }
  end

  -- update them
  if vim.tbl_contains(opts.place, 'statusline') then
    for _, win in ipairs(wins) do
      local stl_cur = vim.api.nvim_win_call(win, M.statusline)
      local stl_last = modules.nvim_opts.get_cache('statusline', { window = win })
      if stl_cur or stl_last then
        modules.nvim_opts.set('statusline', stl_cur, { window = win })
      end
    end
  end
  if vim.tbl_contains(opts.place, 'winbar') then
    for _, win in ipairs(wins) do
      if vim.api.nvim_win_get_height(win) > 1 then
        local wbr_cur = vim.api.nvim_win_call(win, M.winbar)
        local wbr_last = modules.nvim_opts.get_cache('winbar', { window = win })
        if wbr_cur or wbr_last then
          modules.nvim_opts.set('winbar', wbr_cur, { window = win })
        end
      end
    end
  end
  if vim.tbl_contains(opts.place, 'tabline') then
    local tbl_cur = vim.api.nvim_win_call(vim.api.nvim_get_current_win(), tabline)
    local tbl_last = modules.nvim_opts.get_cache('tabline', { global = true })
    if tbl_cur or tbl_last then
      modules.nvim_opts.set('tabline', tbl_cur, { global = true })
    end
  end

  vim.g.actual_curwin = old_actual_curwin
end

--- Sets &tabline option to lualine
local function set_tabline()
  vim.loop.timer_stop(timers.tal_timer)
  vim.cmd([[augroup lualine_tal_refresh | exe "autocmd!" | augroup END]])
  if next(config.tabline) ~= nil then
    vim.loop.timer_start(
      timers.tal_timer,
      0,
      config.options.refresh.tabline,
      modules.utils.timer_call(timers.stl_timer, 'lualine_tal_refresh', function()
        refresh { kind = 'tabpage', place = { 'tabline' }, trigger = 'timer' }
      end, 3, 'lualine: Failed to refresh tabline')
    )
    modules.utils.define_autocmd(
      default_refresh_events,
      '*',
      "call v:lua.require'lualine'.refresh({'kind': 'tabpage', 'place': ['tabline'], 'trigger': 'autocmd'})",
      'lualine_tal_refresh'
    )
    modules.nvim_opts.set('showtabline', 2, { global = true })
  else
    modules.nvim_opts.restore('tabline', { global = true })
    modules.nvim_opts.restore('showtabline', { global = true })
  end
end

--- Sets &statusline option to lualine
--- adds auto command to redraw lualine on VimResized event
local function set_statusline()
  vim.loop.timer_stop(timers.stl_timer)
  vim.cmd([[augroup lualine_stl_refresh | exe "autocmd!" | augroup END]])
  if next(config.sections) ~= nil or next(config.inactive_sections) ~= nil then
    if vim.go.statusline == '' then
      modules.nvim_opts.set('statusline', '%#Normal#', { global = true })
    end
    if config.options.globalstatus then
      modules.nvim_opts.set('laststatus', 3, { global = true })
      vim.loop.timer_start(
        timers.stl_timer,
        0,
        config.options.refresh.statusline,
        modules.utils.timer_call(timers.stl_timer, 'lualine_stl_refresh', function()
          refresh { kind = 'window', place = { 'statusline' }, trigger = 'timer' }
        end, 3, 'lualine: Failed to refresh statusline')
      )
      modules.utils.define_autocmd(
        default_refresh_events,
        '*',
        "call v:lua.require'lualine'.refresh({'kind': 'window', 'place': ['statusline'], 'trigger': 'autocmd'})",
        'lualine_stl_refresh'
      )
    else
      modules.nvim_opts.set('laststatus', 2, { global = true })
      vim.loop.timer_start(
        timers.stl_timer,
        0,
        config.options.refresh.statusline,
        modules.utils.timer_call(timers.stl_timer, 'lualine_stl_refresh', function()
          refresh { kind = 'tabpage', place = { 'statusline' }, trigger = 'timer' }
        end, 3, 'lualine: Failed to refresh statusline')
      )
      modules.utils.define_autocmd(
        default_refresh_events,
        '*',
        "call v:lua.require'lualine'.refresh({'kind': 'tabpage', 'place': ['statusline'], 'trigger': 'autocmd'})",
        'lualine_stl_refresh'
      )
    end
  else
    modules.nvim_opts.restore('statusline', { global = true })
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      modules.nvim_opts.restore('statusline', { window = win })
    end
    modules.nvim_opts.restore('laststatus', { global = true })
  end
end

--- Sets &winbar option to lualine
local function set_winbar()
  vim.loop.timer_stop(timers.wb_timer)
  vim.cmd([[augroup lualine_wb_refresh | exe "autocmd!" | augroup END]])
  if next(config.winbar) ~= nil or next(config.inactive_winbar) ~= nil then
    vim.loop.timer_start(
      timers.stl_timer,
      0,
      config.options.refresh.winbar,
      modules.utils.timer_call(timers.stl_timer, 'lualine_wb_refresh', function()
        refresh { kind = 'tabpage', place = { 'winbar' }, trigger = 'timer' }
      end, 3, 'lualine: Failed to refresh winbar')
    )
    modules.utils.define_autocmd(
      default_refresh_events,
      '*',
      "call v:lua.require'lualine'.refresh({'kind': 'tabpage', 'place': ['winbar'], 'trigger': 'autocmd'})",
      'lualine_wb_refresh'
    )
  elseif vim.fn.has('nvim-0.8') == 1 then
    modules.nvim_opts.restore('winbar', { global = true })
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      modules.nvim_opts.restore('winbar', { window = win })
    end
  end
end

-- lualine.setup function
--- sets new user config
--- This function doesn't load components/theme etc... They are done before
--- first statusline redraw and after new config. This is more efficient when
--- lualine config is done in several setup calls as chunks. This way
--- we don't initialize components just to throw them away. Instead they are
--- initialized when we know we will use them.
--- sets &last_status to 2
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
  set_winbar()
  if package.loaded['lualine.utils.notices'] then
    modules.utils_notices.notice_message_startup()
  end
end

M = {
  setup = setup,
  statusline = status_dispatch('sections'),
  tabline = tabline,
  get_config = modules.config_module.get_config,
  refresh = refresh,
  winbar = status_dispatch('winbar'),
}

return M
