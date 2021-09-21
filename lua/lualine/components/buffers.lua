-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local Buffers = require('lualine.component'):new()
local highlight = require 'lualine.highlight'

local default_options = {
  show_filename_only = true,
  show_modified_status = true,
  max_length = 0,
  filetype_names = {
    TelescopePrompt = 'Telescope',
    dashboard = 'Dashboard',
    packer = 'Packer',
    fzf = 'FZF',
    alpha = 'Alpha',
  },
  buffers_color = {
    active = nil,
    inactive = nil,
  },
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

local Buffer = {}

function Buffer:new(buffer)
  assert(buffer.bufnr, 'Cannot create Buffer without bufnr')
  local newObj = { bufnr = buffer.bufnr, options = buffer.options, highlights = buffer.highlights }
  self.__index = self
  newObj = setmetatable(newObj, self)
  newObj:get_props()
  return newObj
end

function Buffer:get_props()
  self.file = vim.fn.bufname(self.bufnr)
  self.buftype = vim.api.nvim_buf_get_option(self.bufnr, 'buftype')
  self.filetype = vim.api.nvim_buf_get_option(self.bufnr, 'filetype')
  local modified = self.options.show_modified_status and vim.api.nvim_buf_get_option(self.bufnr, 'modified')
  local modified_icon = self.options.icons_enabled and ' ' or ' +'
  self.modified_icon = modified and modified_icon or ''
  self.icon = ''
  if self.options.icons_enabled then
    local dev
    local status, _ = pcall(require, 'nvim-web-devicons')
    if not status then
      dev, _ = '', ''
    elseif self.filetype == 'TelescopePrompt' then
      dev, _ = require('nvim-web-devicons').get_icon 'telescope'
    elseif self.filetype == 'fugitive' then
      dev, _ = require('nvim-web-devicons').get_icon 'git'
    elseif self.filetype == 'vimwiki' then
      dev, _ = require('nvim-web-devicons').get_icon 'markdown'
    elseif self.buftype == 'terminal' then
      dev, _ = require('nvim-web-devicons').get_icon 'zsh'
    elseif vim.fn.isdirectory(self.file) == 1 then
      dev, _ = '', nil
    else
      dev, _ = require('nvim-web-devicons').get_icon(self.file, vim.fn.expand('#' .. self.bufnr .. ':e'))
    end
    if dev then
      self.icon = dev .. ' '
    end
  end
  return self
end

function Buffer:render()
  local name
  if self.ellipse then
    name = '...'
  else
    name = string.format(' %s%s%s ', self.icon, self:name(), self.modified_icon)
  end
  self.len = vim.fn.strchars(name)

  local line = string.format('%%%s@LualineSwitchBuffer@%s%%T', self.bufnr, name)
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

function Buffer:separator_before()
  if self.current or self.aftercurrent then
    return '%S{' .. self.options.section_separators.left .. '}'
  else
    return self.options.component_separators.left
  end
end

function Buffer:separator_after()
  if self.current or self.beforecurrent then
    return '%s{' .. self.options.section_separators.right .. '}'
  else
    return self.options.component_separators.right
  end
end

function Buffer:name()
  if self.options.filetype_names[self.filetype] then
    return self.options.filetype_names[self.filetype]
  elseif self.buftype == 'help' then
    return 'help:' .. vim.fn.fnamemodify(self.file, ':t:r')
  elseif self.buftype == 'terminal' then
    local match = string.match(vim.split(self.file, ' ')[1], 'term:.*:(%a+)')
    return match ~= nil and match or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif vim.fn.isdirectory(self.file) == 1 then
    return vim.fn.fnamemodify(self.file, ':p:.')
  elseif self.file == '' then
    return '[No Name]'
  end
  return self.options.show_filename_only and vim.fn.fnamemodify(self.file, ':t')
    or vim.fn.pathshorten(vim.fn.fnamemodify(self.file, ':p:.'))
end

function Buffers:new(options, child)
  local newObj = self._parent:new(options, child or Buffers)
  default_options.buffers_color = {
    active = get_hl(options.self.section, true),
    inactive = get_hl(options.self.section, false),
  }
  newObj.options = vim.tbl_deep_extend('keep', newObj.options or {}, default_options)
  newObj.highlights = {
    active = highlight.create_component_highlight_group(
      newObj.options.buffers_color.active,
      'buffers_active',
      newObj.options
    ),
    inactive = highlight.create_component_highlight_group(
      newObj.options.buffers_color.inactive,
      'buffers_active',
      newObj.options
    ),
  }
  return newObj
end

function Buffers:update_status()
  local data = {}
  local buffers = {}
  for b = 1, vim.fn.bufnr '$' do
    if vim.fn.buflisted(b) ~= 0 and vim.api.nvim_buf_get_option(b, 'buftype') ~= 'quickfix' then
      buffers[#buffers + 1] = Buffer:new { bufnr = b, options = self.options, highlights = self.highlights }
    end
  end
  local current_bufnr = vim.fn.bufnr()
  local current = -2
  if buffers[1] then
    buffers[1].first = true
  end
  if buffers[#buffers] then
    buffers[#buffers].last = true
  end
  for i, buffer in ipairs(buffers) do
    if buffer.bufnr == current_bufnr then
      buffer.current = true
      current = i
    end
  end
  if buffers[current - 1] then
    buffers[current - 1].beforecurrent = true
  end
  if buffers[current + 1] then
    buffers[current + 1].aftercurrent = true
  end

  local max_length = self.options.max_length
  if max_length == 0 then
    max_length = math.floor(2 * vim.o.columns / 3)
  end
  local total_length
  for i, buffer in pairs(buffers) do
    if buffer.current then
      current = i
    end
  end
  if current == -2 then
    local b = Buffer:new { bufnr = vim.fn.bufnr(), options = self.options, highlights = self.highlights }
    b.current = true
    if self.options.self.section < 'lualine_x' then
      b.last = true
      if #buffers > 0 then
        buffers[#buffers].last = nil
      end
      buffers[#buffers + 1] = b
      current = #buffers
    else
      b.first = true
      if #buffers > 0 then
        buffers[1].first = nil
      end
      table.insert(buffers, 1, b)
      current = 1
    end
  end
  local current_buffer = buffers[current]
  data[#data + 1] = current_buffer:render()
  total_length = current_buffer.len
  local i = 0
  local before, after
  while true do
    i = i + 1
    before = buffers[current - i]
    after = buffers[current + i]
    local rendered_before, rendered_after
    if before == nil and after == nil then
      break
    end
    if before then
      rendered_before = before:render()
      total_length = total_length + before.len
    end
    if after then
      rendered_after = after:render()
      total_length = total_length + after.len
    end
    if total_length > max_length then
      break
    end
    if before then
      table.insert(data, 1, rendered_before)
    end
    if after then
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

  return table.concat(data)
end

vim.cmd [[
  function! LualineSwitchBuffer(bufnr, mouseclicks, mousebutton, modifiers)
    execute ":buffer " . a:bufnr
  endfunction
]]

return Buffers
