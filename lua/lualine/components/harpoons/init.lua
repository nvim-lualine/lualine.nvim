-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local require = require('lualine_require').require
local Harpoon = require('lualine.components.harpoons.harpoon')
local M = require('lualine.component'):extend()
local highlight = require('lualine.highlight')
local harpoon_plug = require('harpoon')

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
    harpoon = 'Harpoon',
  },
  use_mode_colors = false,
  harpoons_color = {
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
---returns the proper hl for harpoon in section. Used for setting default highlights
---@param section string name of section harpoons component is in
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

function M:init(options)
  M.super.init(self, options)
  -- if use_mode_colors is set, use a function so that the colors update
  local default_active = options.use_mode_colors
      and function()
        return get_hl('lualine_' .. options.self.section, true)
      end
    or get_hl('lualine_' .. options.self.section, true)
  default_options.harpoons_color = {
    active = default_active,
    inactive = get_hl('lualine_' .. options.self.section, false),
  }
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  if self.options.component_name == 'harpoons' then
    self.highlights = {
      active = self:create_hl(self.options.harpoons_color.active, 'active'),
      inactive = self:create_hl(self.options.harpoons_color.inactive, 'inactive'),
    }
  end

  -- refresh if harpoon makes changes
  local function refresh_lualine()
    require('lualine').refresh()
  end
  harpoon_plug:extend {
    NAVIGATE = refresh_lualine,
    ADD = refresh_lualine,
    REMOVE = refresh_lualine,
    REPLACE = refresh_lualine,
  }
end

function M:new_harpoon(hpnr, bufnr)
  if not bufnr or bufnr < 0 then
    bufnr = nil
    if not hpnr then
      bufnr = vim.fn.bufnr()
    end
  end
  return Harpoon:new {
    hpnr = hpnr,
    bufnr = bufnr,
    options = self.options,
    highlights = self.highlights,
  }
end

function M:harpoons()
  local buffers = {}
  local harpoons = {}
  for _, b in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      table.insert(buffers, b)
    end
  end

  local currIsHarpoon = false
  for i, h in pairs(harpoon_plug:list().items) do
    if h ~= nil then
      local bufnr = -1
      local hPath = vim.loop.fs_realpath(h.value)
      if hPath then
        bufnr = vim.fn.bufnr(hPath)
      end
      if bufnr ~= -1 then
        currIsHarpoon = true
      end
      table.insert(harpoons, self:new_harpoon(i, bufnr))
    end
  end

  if not currIsHarpoon then
    table.insert(harpoons, self:new_harpoon())
  end

  return harpoons
end

function M:update_status()
  local data = {}
  local harpoons = self:harpoons()
  local current = -2
  -- mark the first, last, current, before current, after current harpoons
  -- for rendering
  if harpoons[1] then
    harpoons[1].first = true
  end
  if harpoons[#harpoons] then
    harpoons[#harpoons].last = true
  end
  for i, harpoon in ipairs(harpoons) do
    if harpoon:is_current() then
      harpoon.current = true
      current = i
    end
  end
  if harpoons[current - 1] then
    harpoons[current - 1].beforecurrent = true
  end
  if harpoons[current + 1] then
    harpoons[current + 1].aftercurrent = true
  end

  local max_length = self.options.max_length
  if type(max_length) == 'function' then
    max_length = max_length(self)
  end

  if max_length == 0 then
    max_length = math.floor(2 * vim.o.columns / 3)
  end
  local total_length
  for i, harpoon in pairs(harpoons) do
    if harpoon.current then
      current = i
    end
  end

  -- start drawing from current harpoon and draw left and right of it until
  -- all harpoons are drawn or max_length has been reached.
  if current == -2 then
    local b = self:new_harpoon()
    b.current = true
    if self.options.self.section < 'x' then
      b.last = true
      if #harpoons > 0 then
        harpoons[#harpoons].last = nil
      end
      harpoons[#harpoons + 1] = b
      current = #harpoons
    else
      b.first = true
      if #harpoons > 0 then
        harpoons[1].first = nil
      end
      table.insert(harpoons, 1, b)
      current = 1
    end
  end
  local current_harpoon = harpoons[current]
  data[#data + 1] = current_harpoon:render()
  total_length = current_harpoon.len
  local i = 0
  local before, after
  while true do
    i = i + 1
    before = harpoons[current - i]
    after = harpoons[current + i]
    local rendered_before, rendered_after
    if before == nil and after == nil then
      break
    end
    -- draw left most undrawn harpoon if fits in max_length
    if before then
      rendered_before = before:render()
      total_length = total_length + before.len
      if total_length > max_length then
        break
      end
      table.insert(data, 1, rendered_before)
    end
    -- draw right most undrawn harpoon if fits in max_length
    if after then
      rendered_after = after:render()
      total_length = total_length + after.len
      if total_length > max_length then
        break
      end
      data[#data + 1] = rendered_after
    end
  end
  -- draw ellipsis (...) on relevant sides if all harpoons don't fit in max_length
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

vim.cmd([[
  function! LualineSwitchHarpoon(hpnr, mouseclicks, mousebutton, modifiers)
    execute ":lua require(\"harpoon\"):list():select(" . a:hpnr . ")"
  endfunction
]])

return M
