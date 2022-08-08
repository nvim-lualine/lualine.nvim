-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local require = require('lualine_require').require
local Buffer = require('lualine.components.buffers.buffer')
local M = require('lualine.component'):extend()
local highlight = require('lualine.highlight')

local default_options = {
  show_filename_only = true,
  hide_filename_extension = false,
  show_modified_status = true,
  mode = 0,
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
  symbols = {
    modified = ' ●',
    alternate_file = '#',
    directory = '',
  },
}

-- This function is duplicated in tabs
---returns the proper hl for buffer in section. Used for setting default highlights
---@param section string name of section buffers component is in
---@param is_active boolean
---@return string hl name
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

function M:init(options)
  M.super.init(self, options)
  default_options.buffers_color = {
    active = get_hl('lualine_' .. options.self.section, true),
    inactive = get_hl('lualine_' .. options.self.section, false),
  }
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  if self.options.component_name == 'buffers' then
    self.highlights = {
      active = self:create_hl(self.options.buffers_color.active, 'active'),
      inactive = self:create_hl(self.options.buffers_color.inactive, 'inactive'),
    }
  end
end

function M:new_buffer(bufnr, buf_index)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  buf_index = buf_index or ''
  return Buffer:new {
    bufnr = bufnr,
    buf_index = buf_index,
    options = self.options,
    highlights = self.highlights,
  }
end

function M:buffers()
  local buffers = {}
  M.bufpos2nr = {}
  for b = 1, vim.fn.bufnr('$') do
    if vim.fn.buflisted(b) ~= 0 and vim.api.nvim_buf_get_option(b, 'buftype') ~= 'quickfix' then
      buffers[#buffers + 1] = self:new_buffer(b, #buffers + 1)
      M.bufpos2nr[#buffers] = b
    end
  end

  return buffers
end

function M:update_status()
  local data = {}
  local buffers = self:buffers()
  local current = -2
  -- mark the first, last, current, before current, after current buffers
  -- for rendering
  if buffers[1] then
    buffers[1].first = true
  end
  if buffers[#buffers] then
    buffers[#buffers].last = true
  end
  for i, buffer in ipairs(buffers) do
    if buffer:is_current() then
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
  if type(max_length) == 'function' then
    max_length = max_length(self)
  end

  if max_length == 0 then
    max_length = math.floor(2 * vim.o.columns / 3)
  end
  local total_length
  for i, buffer in pairs(buffers) do
    if buffer.current then
      current = i
    end
  end
  -- start drawing from current buffer and draw left and right of it until
  -- all buffers are drawn or max_length has been reached.
  if current == -2 then
    local b = self:new_buffer()
    b.current = true
    if self.options.self.section < 'x' then
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
    -- draw left most undrawn buffer if fits in max_length
    if before then
      rendered_before = before:render()
      total_length = total_length + before.len
      if total_length > max_length then
        break
      end
      table.insert(data, 1, rendered_before)
    end
    -- draw right most undrawn buffer if fits in max_length
    if after then
      rendered_after = after:render()
      total_length = total_length + after.len
      if total_length > max_length then
        break
      end
      data[#data + 1] = rendered_after
    end
  end
  -- draw ellipsis (...) on relevant sides if all buffers don't fit in max_length
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

function M:draw()
  self.status = ''
  self.applied_separator = ''

  if self.options.cond ~= nil and self.options.cond() ~= true then
    return self.status
  end
  local status = self:update_status()
  if type(status) == 'string' and #status > 0 then
    self.status = status
    self:apply_section_separators()
    self:apply_separator()
  end
  return self.status
end

function M.buffer_jump(buf_pos, bang)
  if buf_pos == '$' then
    buf_pos = #M.bufpos2nr
  else
    buf_pos = tonumber(buf_pos)
  end
  if buf_pos < 1 or buf_pos > #M.bufpos2nr then
    if bang ~= '!' then
      error('Error: Unable to jump buffer position out of range')
    else
      return
    end
  end
  vim.api.nvim_set_current_buf(M.bufpos2nr[buf_pos])
end

vim.cmd([[
  function! LualineSwitchBuffer(bufnr, mouseclicks, mousebutton, modifiers)
    execute ":buffer " . a:bufnr
  endfunction

  command! -nargs=1 -bang LualineBuffersJump call v:lua.require'lualine.components.buffers'.buffer_jump(<f-args>, "<bang>")
]])

return M
