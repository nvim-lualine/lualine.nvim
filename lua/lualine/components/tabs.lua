-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local Tabs = require('lualine.component'):new()
local highlight = require 'lualine.highlight'

local default_options = {
  max_length = 0,
  mode = 0,
}

local function get_hl(section, is_active)
  local suffix = is_active and '_normal' or '_inactive'
  local section_redirects = {
    lualine_x = 'lualine_c',
    lualine_y = 'lualine_b',
    lualine_z = 'lualine_a',
  }
  if section_redirects[section] then
    section = highlight.highlight_exists(section .. suffix) and section or section_redirects[section]
  end
  return section .. suffix
end

local Tab = {}

function Tab:new(tab)
  assert(tab.tabnr, 'Cannot create Tab without tabnr')
  local newObj = {
    tabnr = tab.tabnr,
    options = tab.options,
    highlights = tab.highlights,
  }
  self.__index = self
  newObj = setmetatable(newObj, self)
  return newObj
end

function Tab:label()
  local buflist = vim.fn.tabpagebuflist(self.tabnr)
  local winnr = vim.fn.tabpagewinnr(self.tabnr)
  local bufnr = buflist[winnr]
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, '&buftype')
  if buftype == 'help' then
    return 'help:' .. vim.fn.fnamemodify(file, ':t:r')
  elseif buftype == 'terminal' then
    local match = string.match(vim.split(file, ' ')[1], 'term:.*:(%a+)')
    return match ~= nil and match or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif vim.fn.isdirectory(file) == 1 then
    return vim.fn.fnamemodify(file, ':p:.')
  elseif file == '' then
    return '[No Name]'
  end
  return vim.fn.fnamemodify(file, ':t')
end

function Tab:render()
  local name
  if self.ellipse then
    name = '...'
  else
    if self.options.mode == 0 then
      name = string.format('%s%s ', (self.last or not self.first) and ' ' or '', tostring(self.tabnr))
    elseif self.options.mode == 1 then
      name = string.format('%s%s ', (self.last or not self.first) and ' ' or '', self:label())
    else
      name = string.format('%s%s %s ', (self.last or not self.first) and ' ' or '', tostring(self.tabnr), self:label())
    end
  end
  self.len = #name
  local line = string.format('%%%s@LualineSwitchTab@%s%%T', self.tabnr, name)
  line = highlight.component_format_highlight(self.highlights[(self.current and 'active' or 'inactive')]) .. line

  if self.options.self.section < 'lualine_x' and not self.first then
    local sep_before = self:separator_before()
    line = sep_before .. line
    self.len = self.len + vim.fn.strchars(sep_before)
  elseif self.options.self.section >= 'lualine_x' and not self.last then
    local sep_after = self:separator_after()
    line = line .. sep_after
    self.len = self.len + vim.fn.strchars(sep_after)
  end
  return line
end

function Tab:separator_before()
  if self.current or self.aftercurrent then
    return '%S{' .. self.options.section_separators.left .. '}'
  else
    return self.options.component_separators.left
  end
end

function Tab:separator_after()
  if self.current or self.beforecurrent then
    return '%s{' .. self.options.section_separators.right .. '}'
  else
    return self.options.component_separators.right
  end
end

function Tabs:new(options, child)
  local newObj = self._parent:new(options, child or Tabs)
  default_options.tabs_color = {
    active = get_hl(options.self.section, true),
    inactive = get_hl(options.self.section, false),
  }
  newObj.options = vim.tbl_deep_extend('keep', newObj.options or {}, default_options)
  -- stylua: ignore
  newObj.highlights = {
    active = highlight.create_component_highlight_group(
      newObj.options.tabs_color.active,
      'tabs_active',
      newObj.options
    ),
    inactive = highlight.create_component_highlight_group(
      newObj.options.tabs_color.inactive,
      'tabs_active',
      newObj.options
    ),
  }
  return newObj
end

function Tabs:update_status()
  local data = {}
  local tabs = {}
  for t = 1, vim.fn.tabpagenr '$' do
    tabs[#tabs + 1] = Tab:new { tabnr = t, options = self.options, highlights = self.highlights }
  end
  local current = vim.api.nvim_get_current_tabpage()
  tabs[1].first = true
  tabs[#tabs].last = true
  if tabs[current] then
    tabs[current].current = true
  end
  if tabs[current - 1] then
    tabs[current - 1].beforecurrent = true
  end
  if tabs[current + 1] then
    tabs[current + 1].aftercurrent = true
  end

  local max_length = self.options.max_length
  if max_length == 0 then
    max_length = math.floor(vim.o.columns / 3)
  end
  local total_length
  for i, tab in pairs(tabs) do
    if tab.current then
      current = i
    end
  end
  local current_tab = tabs[current]
  if current_tab == nil then
    local t = Tab:new { tabnr = vim.fn.tabpagenr() }
    t.current = true
    t.last = true
    data[#data + 1] = t:render()
  else
    data[#data + 1] = current_tab:render()
    total_length = current_tab.len
    local i = 0
    local before, after
    while true do
      i = i + 1
      before = tabs[current - i]
      after = tabs[current + i]
      local rendered_before, rendered_after
      if before == nil and after == nil then
        break
      end
      if before then
        rendered_before = before:render()
        total_length = total_length + before.len
        if total_length > max_length then
          break
        end
        table.insert(data, 1, rendered_before)
      end
      if after then
        rendered_after = after:render()
        total_length = total_length + after.len
        if total_length > max_length then
          break
        end
        data[#data + 1] = rendered_after
      end
    end
    if total_length > max_length then
      if before ~= nil then
        before.ellipse = true
        before.first = true
        table.insert(data, 1, before:render())
      end
      if after ~= nil then
        after.ellipse = true
        after.last = true
        data[#data + 1] = after:render()
      end
    end
  end

  return table.concat(data)
end

vim.cmd [[
  function! LualineSwitchTab(tabnr, mouseclicks, mousebutton, modifiers)
    execute a:tabnr . "tabnext"
  endfunction
]]

return Tabs
