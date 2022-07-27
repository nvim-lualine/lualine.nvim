-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local lualine_require = require('lualine_require')
local require = lualine_require.require
local M = require('lualine.utils.class'):extend()
local modules = lualine_require.lazy_require {
  highlight = 'lualine.highlight',
  utils_notices = 'lualine.utils.notices',
  fn_store = 'lualine.utils.fn_store',
}

-- Used to provide a unique id for each component
local component_no = 1
function M._reset_components()
  component_no = 1
end

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
  self:set_on_click()
end

---sets the default separator for component based on whether the component
---is in left sections or right sections when separator option is omitted.
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
    self.options.color_highlight = self:create_hl(self.options.color)
  end
  -- setup icon highlight
  if type(self.options.icon) == 'table' and self.options.icon.color then
    self.options.icon_color_highlight = self:create_hl(self.options.icon.color)
  end
end

---Setup on click function so they can be added during drawing.
function M:set_on_click()
  if self.options.on_click ~= nil then
    if vim.fn.has('nvim-0.8') == 0 then
      modules.utils_notices.add_notice(
        '### Options.on_click\nSorry `on_click` can only be used in neovim 0.8 or higher.\n'
      )
      self.options.on_click = nil
      return
    end
    self.on_click_id = modules.fn_store.register_fn(self.component_no, self.options.on_click)
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
      -- When component has changed the highlight at beginning
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
    hl_fmt, M.color_fn_cache = self:format_hl(self.options.color_highlight)
    self.status = hl_fmt .. self.status
  end
  if type(self.options.separator) ~= 'table' and self.status:find('%%#') then
    -- Apply default highlight only when we aren't applying trans sep and
    -- the component has changed it's hl. Since we won't be applying
    -- regular sep in those cases so ending with default hl isn't necessary
    self.status = self.status .. default_highlight
    -- Also put it in applied sep so when sep get striped so does the hl
    self.applied_separator = default_highlight
  end
  -- Prepend default hl when the component doesn't start with hl otherwise
  -- color in previous component can cause side effect
  if not self.status:find('^%%#') then
    self.status = default_highlight .. self.status
  end
end

---apply icon to component (appends/prepends component with icon)
function M:apply_icon()
  local icon = self.options.icon
  if self.options.icons_enabled and icon then
    if type(icon) == 'table' then
      icon = icon[1]
    end
    if
      self.options.icon_color_highlight
      and type(self.options.icon) == 'table'
      and self.options.icon.align == 'right'
    then
      self.status = table.concat {
        self.status,
        ' ',
        self:format_hl(self.options.icon_color_highlight),
        icon,
        self:get_default_hl(),
      }
    elseif self.options.icon_color_highlight then
      self.status = table.concat {
        self:format_hl(self.options.icon_color_highlight),
        icon,
        self:get_default_hl(),
        ' ',
        self.status,
      }
    elseif type(self.options.icon) == 'table' and self.options.icon.align == 'right' then
      self.status = table.concat({ self.status, icon }, ' ')
    else
      self.status = table.concat({ icon, self.status }, ' ')
    end
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

---Add on click funtion description to already drawn item
function M:apply_on_click()
  if self.on_click_id then
    self.status = self:format_fn(self.on_click_id, self.status)
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
    return self:format_hl(self.options.color_highlight)
  elseif self.default_hl then
    return self.default_hl
  else
    return modules.highlight.format_highlight(self.options.self.section)
  end
end

---create a lualine highlight for color
---@param color table|string|function defined color for hl
---@param hint string|nil hint for hl name
---@return table an identifier to later retrieve the hl for application
function M:create_hl(color, hint)
  hint = hint and self.options.component_name .. '_' .. hint or self.options.component_name
  return modules.highlight.create_component_highlight_group(color, hint, self.options, false)
end

---Get stl formatted hl group for hl_token
---@param hl_token table identifier received from create_hl or create_component_highlight_group
---@return string stl formatted hl group for hl_token
function M:format_hl(hl_token)
  return modules.highlight.component_format_highlight(hl_token)
end

---Wrap str with click format for function of id
---@param id number
---@param str string
---@return string
function M:format_fn(id, str)
  return string.format("%%%d@v:lua.require'lualine.utils.fn_store'.call_fn@%s%%T", id, str)
end

-- luacheck: push no unused args
---actual function that updates a component. Must be overwritten with component functionality
function M:update_status(is_focused) end
-- luacheck: pop

---driver code of the class
---@param default_highlight string default hl group of section where component resides
---@param is_focused boolean|number whether drawing for active or inactive statusline.
---@return string stl formatted rendering string for component
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
    self:apply_on_click()
    self:apply_highlights(default_highlight)
    self:apply_section_separators()
    self:apply_separator()
  end
  return self.status
end

return M
