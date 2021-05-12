-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local highlight = require('lualine.highlight')
local loader = require('lualine.utils.loader')
local utils_section = require('lualine.utils.section')
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
local function get_extension_sections()
  for _, extension in ipairs(config.extensions) do
    for _, filetype in ipairs(extension.filetypes) do
      local current_ft = vim.api.nvim_buf_get_option(
                             vim.fn.winbufnr(vim.g.statusline_winid), 'filetype')
      if current_ft == filetype then return extension.sections end
    end
  end
  return nil
end

local function status_dispatch()
  -- disable on specific filetypes
  local current_ft = vim.api.nvim_buf_get_option(
                         vim.fn.winbufnr(vim.g.statusline_winid), 'filetype')
  for _, ft in pairs(config.options.disabled_filetypes) do
    if ft == current_ft then
      vim.wo.statusline = ''
      return ''
    end
  end
  local extension_sections = get_extension_sections()
  if vim.g.statusline_winid == vim.fn.win_getid() then
    if extension_sections ~= nil then
      return statusline(extension_sections, true)
    end
    return statusline(config.sections, true)
  else
    if extension_sections ~= nil then
      return statusline(extension_sections, false)
    end
    return statusline(config.inactive_sections, false)
  end
end

local function tabline() return statusline(config.tabline, true) end

local function setup_theme()
  local async_loader
  async_loader = vim.loop.new_async(vim.schedule_wrap(
                                        function()
        local function get_theme_from_config()
          local theme_name = config.options.theme
          if type(theme_name) == 'string' then
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
        vim.api.nvim_exec([[
          augroup lualine
            autocmd ColorScheme * lua require'lualine.utils.utils'.reload_highlights()
          augroup END
          ]], false)
        async_loader:close()
      end))
  async_loader:send()
end

local function set_tabline()
  if next(config.tabline) ~= nil then
    vim.o.tabline = '%!v:lua.require\'lualine\'.tabline()'
    vim.o.showtabline = 2
  end
end

local function set_statusline()
  if next(config.sections) ~= nil or next(config.inactive_sections) ~= nil then
    vim.o.statusline = '%!v:lua.require\'lualine\'.statusline()'
    vim.api.nvim_exec([[
      augroup lualine
        autocmd!
        autocmd WinLeave,BufLeave * lua vim.wo.statusline=require'lualine'.statusline()
        autocmd BufWinEnter,WinEnter,BufEnter * set statusline<
        autocmd VimResized * redrawstatus
      augroup END
    ]], false)
  end
end

local function setup(user_config)
  if user_config then
    config_module.apply_configuration(user_config)
  elseif vim.g.lualine then
    vim.schedule(function()
      vim.api.nvim_err_writeln(
          [[Lualine: lualine will stop supporting vimscript soon, change your config to lua or wrap it around lua << EOF ... EOF]]) -- luacheck: ignore
    end)
    config_module.apply_configuration(vim.g.lualine)
  end
  setup_theme()
  loader.load_all(config)
  set_statusline()
  set_tabline()
end

return {setup = setup, statusline = status_dispatch, tabline = tabline}
