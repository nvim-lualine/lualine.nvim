-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local require = require('lualine_require').require
local highlight = require('lualine.highlight')
local M = require('lualine.utils.class'):extend()

-- Used to provide a unique id for each component
local component_no = 1

-- variable to store component output for manipulation
M.status = ''

function M:__tostring()
  local str = 'Component: ' .. self.options.component_name
  if self.debug then
    str = str .. '\n---------------------\n' .. vim.inspect(self)
  end
  return str
end

M.__is_lualine_component = true

---initialize new component
---@param options table options for component
function M:init(options)
  self.options = options or {}
  component_no = component_no + 1
  if not self.options.component_name then
    self.options.component_name = tostring(component_no)
  end
  self.component_no = component_no
  self:set_separator()
  self:create_option_highlights()
end

---sets the default separator for component based on whether the component
---is in left sections or right sections when separator option is omited.
function M:set_separator()
  if self.options.separator == nil then
    if self.options.component_separators then
      if self.options.self.section < 'x' then
        self.options.separator = self.options.component_separators.left
      else
        self.options.separator = self.options.component_separators.right
      end
    end
  end
end

---creates hl group from color option
function M:create_option_highlights()
  -- set custom highlights
  if self.options.color then
    self.options.color_highlight = highlight.create_component_highlight_group(
      self.options.color,
      self.options.component_name,
      self.options
    )
  end
end

---adds spaces to left and right of a component
function M:apply_padding()
  local padding = self.options.padding
  local l_padding, r_padding
  if padding == nil then
    padding = 1
  end
  if type(padding) == 'number' then
    l_padding, r_padding = padding, padding
  elseif type(padding) == 'table' then
    l_padding, r_padding = padding.left, padding.right
  end
  if l_padding then
    if self.status:find('%%#.*#') == 1 then
      -- When component has changed the highlight at begining
      -- we will add the padding after the highlight
      local pre_highlight = vim.fn.matchlist(self.status, [[\(%#.\{-\}#\)]])[2]
      self.status = pre_highlight .. string.rep(' ', l_padding) .. self.status:sub(#pre_highlight + 1, #self.status)
    else
      self.status = string.rep(' ', l_padding) .. self.status
    end
  end
  if r_padding then
    self.status = self.status .. string.rep(' ', r_padding)
  end
end

---applies custom highlights for component
function M:apply_highlights(default_highlight)
  if self.options.color_highlight then
    local hl_fmt
    hl_fmt, M.color_fn_cache = highlight.component_format_highlight(self.options.color_highlight)
    self.status = hl_fmt .. self.status
  end
  if type(self.options.separator) ~= 'table' and self.status:find('%%#') then
    -- Apply default highlight only when we aren't applying trans sep and
    -- the component has changed it's hl. since we won't be applying
    -- regular sep in those cases so ending with default hl isn't neccessay
    self.status = self.status .. default_highlight
    -- Also put it in applied sep so when sep get struped so does the hl
    self.applied_separator = default_highlight
  end
  -- Prepend default hl when the component doesn't start with hl otherwise
  -- color in previous component can cause side effect
  if not self.status:find('^%%#') then
    self.status = default_highlight .. self.status
  end
end

---apply icon in front of component (prepemds component with icon)
function M:apply_icon()
  if self.options.icons_enabled and self.options.icon then
    self.status = self.options.icon .. ' ' .. self.status
  end
end

---apply separator at end of component only when
---custom highlights haven't affected background
function M:apply_separator()
  local separator = self.options.separator
  if type(separator) == 'table' then
    if self.options.separator[2] == '' then
      if self.options.self.section < 'x' then
        separator = self.options.component_separators.left
      else
        separator = self.options.component_separators.right
      end
    else
      return
    end
  end
  if separator and #separator > 0 then
    self.status = self.status .. separator
    self.applied_separator = self.applied_separator .. separator
  end
end

---apply transitional separator for the component
function M:apply_section_separators()
  if type(self.options.separator) ~= 'table' then
    return
  end
  if self.options.separator.left ~= nil and self.options.separator.left ~= '' then
    self.status = string.format('%%s{%s}%s', self.options.separator.left, self.status)
    self.strip_previous_separator = true
  end
  if self.options.separator.right ~= nil and self.options.separator.right ~= '' then
    self.status = string.format('%s%%S{%s}', self.status, self.options.separator.right)
  end
end

---remove separator from tail of this component.
---called by lualine.utils.sections.draw_section to manage unnecessary separators
function M:strip_separator()
  if not self.applied_separator then
    self.applied_separator = ''
  end
  self.status = self.status:sub(1, (#self.status - #self.applied_separator))
  self.applied_separator = nil
  return self.status
end

function M:get_default_hl()
  if self.options.color_highlight then
    return highlight.component_format_highlight(self.options.color_highlight)
  elseif self.default_hl then
    return self.default_hl
  else
    return highlight.format_highlight(self.options.self.section)
  end
end

-- luacheck: push no unused args
---actual function that updates a component. Must be overwritten with component functionality
function M:update_status(is_focused) end
-- luacheck: pop

---driver code of the class
function M:draw(default_highlight, is_focused)
  self.status = ''
  self.applied_separator = ''

  if self.options.cond ~= nil and self.options.cond() ~= true then
    return self.status
  end
  self.default_hl = default_highlight
  local status = self:update_status(is_focused)
  if self.options.fmt then
    status = self.options.fmt(status or '')
  end
  if type(status) == 'string' and #status > 0 then
    self.status = status
    self:apply_icon()
    self:apply_padding()
    self:apply_highlights(default_highlight)
    self:apply_section_separators()
    self:apply_separator()
  end
  return self.status
end

return M
