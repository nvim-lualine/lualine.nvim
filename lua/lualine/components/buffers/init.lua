-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local require = require('lualine_require').require
local Buffer = require 'lualine.components.buffers.buffer'
local M = require('lualine.component'):extend()
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

function M:init(options)
  M.super.init(self, options)
  default_options.buffers_color = {
    active = get_hl(options.self.section, true),
    inactive = get_hl(options.self.section, false),
  }
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  self.highlights = {
    active = highlight.create_component_highlight_group(
      self.options.buffers_color.active,
      'buffers_active',
      self.options
    ),
    inactive = highlight.create_component_highlight_group(
      self.options.buffers_color.inactive,
      'buffers_active',
      self.options
    ),
  }
end

function M:update_status()
  local data = {}
  local buffers = {}
  for b = 1, vim.fn.bufnr '$' do
    if vim.fn.buflisted(b) ~= 0 and vim.api.nvim_buf_get_option(b, 'buftype') ~= 'quickfix' then
      buffers[#buffers + 1] = Buffer { bufnr = b, options = self.options, highlights = self.highlights }
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
    local b = Buffer { bufnr = vim.fn.bufnr(), options = self.options, highlights = self.highlights }
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

return M
