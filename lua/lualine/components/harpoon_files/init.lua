local require = require('lualine_require').require
local Harpoon_file = require('lualine.components.harpoon_files.harpoon_file')
local M = require('lualine.component'):extend()
local highlight = require('lualine.highlight')
local hp_marks = require('harpoon.mark')

local default_options = {
  show_filename_only = true,
  hide_filename_extension = false,
  use_mode_colors = false,
  max_length = 0,
  harpoon_files_color = {
    active = nil,
    inactive = nil
  }
}

-- This function is duplicated in tabs / buffers
---returns the proper hl for buffer in section. Used for setting default highlights
---@param section string name of section buffers component is in
---@param is_active boolean
---@return string hl name
local function get_hl(section, is_active)
  local suffix = is_active and highlight.get_mode_suffix() or '_inactive'
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

-- Same init as buffers
function M:init(options)
  M.super.init(self, options)
  -- if use_mode_colors is set, use a function so that the colors update
  local default_active = options.use_mode_colors
      and function()
        return get_hl('lualine_' .. options.self.section, true)
      end
      or get_hl('lualine_' .. options.self.section, true)
  default_options.harpoon_files_color = {
    active = default_active,
    inactive = get_hl('lualine_' .. options.self.section, false),
  }
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  if self.options.component_name == 'harpoon_files' then
    self.highlights = {
      active = self:create_hl(self.options.harpoon_files_color.active, 'active'),
      inactive = self:create_hl(self.options.harpoon_files_color.inactive, 'inactive'),
    }
  end
end

function M:new_harpoon_file(file_infos)
  return Harpoon_file:new {
    options = self.options,
    highlights = self.highlights,
    infos = file_infos
  }
end

function M:harpoon_files()
  local data = {}

  for idx = 1, hp_marks.get_length() do
    local file_infos = hp_marks.get_marked_file(idx)
    data[idx] = self:new_harpoon_file(file_infos)
  end

  return data
end

function M:update_status()
  local hp_files = self:harpoon_files()

  -- return empty data if no harpoon_files
  if hp_files[1] == nil then
    return {}
  end

  local current = -2

  -- mark the first, last, current, before current, after current harpoon_files
  -- for rendering
  if hp_files[1] then
    hp_files[1].first = true
  end
  if hp_files[#hp_files] then
    hp_files[#hp_files].last = true
  end
  for i, hp_file in ipairs(hp_files) do
    if hp_file:is_current() then
      hp_file.current = true
      current = i
    end
  end
  if hp_files[current - 1] then
    hp_files[current - 1].beforecurrent = true
  end
  if hp_files[current + 1] then
    hp_files[current + 1].aftercurrent = true
  end

  local max_length = self.options.max_length
  if type(max_length) == 'function' then
    max_length = max_length(self)
  end

  if max_length == 0 then
    max_length = math.floor(2 * vim.o.columns / 3)
  end
  local total_length

  local data = {}

  -- Current file not in harpoon
  if current == -2 then
    current = 1
  end

  local current_hp_file = hp_files[current]
  data[#data + 1] = current_hp_file:render()
  total_length = current_hp_file.len

  local i = 0
  local before, after
  while true do
    i = i + 1
    before = hp_files[current - i]
    after = hp_files[current + i]
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

return M
