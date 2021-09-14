-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local highlight = require 'lualine.highlight'

-- Used to provide a unique id for each component
local component_no = 1

local function check_deprecated_options(options)
  local function rename_notice(before, now)
    if options[before] then
      require('lualine.utils.notices').add_notice(string.format(
        [[
### option.%s
%s option has been renamed to `%s`. Please use `%s` instead in your config
for %s component.
]],
        before,
        before,
        now,
        now,
        options.component_name or 'function'
      ))
      options[now] = options[before]
      options[before] = nil
    end
  end
  rename_notice('format', 'fmt')
  rename_notice('condition', 'cond')
end
local Component = {
  -- Creates a new component
  new = function(self, options, child)
    local new_component = {}
    new_component.options = options
    new_component._parent = child or self
    setmetatable(new_component, { __index = new_component._parent })
    -- Operation that are required for creating new components but not for inheritence
    if options ~= nil then
      component_no = component_no + 1
      check_deprecated_options(new_component.options)
      if not options.component_name then
        new_component.options.component_name = tostring(component_no)
      end
      new_component.component_no = component_no
      new_component:set_separator()
      new_component:create_option_highlights()
    end
    return new_component
  end,

  set_separator = function(self)
    if self.options.separator == nil then
      if self.options.component_separators then
        if self.options.self.section < 'lualine_x' then
          self.options.separator = self.options.component_separators.left
        else
          self.options.separator = self.options.component_separators.right
        end
      end
    end
  end,

  create_option_highlights = function(self)
    -- set custom highlights
    if self.options.color then
      self.options.color_highlight = highlight.create_component_highlight_group(
        self.options.color,
        self.options.component_name,
        self.options
      )
    end
  end,

  -- set upper or lower case
  apply_case = function(self)
    -- Donn't work on components that emit vim statusline escaped chars
    if self.status:find '%%' and not self.status:find '%%%%' then
      return
    end
    if self.options.upper == true then
      self.status = self.status:upper()
    elseif self.options.lower == true then
      self.status = self.status:lower()
    end
  end,

  -- Adds spaces to left and right of a component
  apply_padding = function(self)
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
      if self.status:find '%%#.*#' == 1 then
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
  end,

  -- Applies custom highlights for component
  apply_highlights = function(self, default_highlight)
    if self.options.color_highlight then
      self.status = highlight.component_format_highlight(self.options.color_highlight) .. self.status
    end
    if type(self.options.separator) ~= 'table' and self.status:find '%%#' then
      -- Apply default highlight only when we aren't applying trans sep and
      -- the component has changed it's hl. since we won't be applying
      -- regular sep in those cases so ending with default hl isn't neccessay
      self.status = self.status .. default_highlight
      -- Also put it in applied sep so when sep get struped so does the hl
      self.applied_separator = default_highlight
    end
    -- Prepend default hl when the component doesn't start with hl otherwise
    -- color in previous component can cause side effect
    if not self.status:find '^%%#' then
      self.status = default_highlight .. self.status
    end
  end,

  -- Apply icon in front of component
  apply_icon = function(self)
    if self.options.icons_enabled and self.options.icon then
      self.status = self.options.icon .. ' ' .. self.status
    end
  end,

  -- Apply separator at end of component only when
  -- custom highlights haven't affected background
  apply_separator = function(self)
    local separator = self.options.separator
    if type(separator) == 'table' then
      if self.options.separator[2] == '' then
        if self.options.self.section < 'lualine_x' then
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
  end,

  apply_section_separators = function(self)
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
  end,

  strip_separator = function(self)
    if not self.applied_separator then
      self.applied_separator = ''
    end
    self.status = self.status:sub(1, (#self.status - #self.applied_separator))
    self.applied_separator = nil
    return self.status
  end,

  -- variable to store component output for manipulation
  status = '',
  -- Actual function that updates a component. Must be overwritten with component functionality
  -- luacheck: push no unused args
  update_status = function(self, is_focused) end,
  -- luacheck: pop

  -- Driver code of the class
  draw = function(self, default_highlight, is_focused)
    self.status = ''
    self.applied_separator = ''

    if self.options.cond ~= nil and self.options.cond() ~= true then
      return self.status
    end
    local status = self:update_status(is_focused)
    if self.options.fmt then
      status = self.options.fmt(status or '')
    end
    if type(status) == 'string' and #status > 0 then
      self.status = status
      self:apply_icon()
      self:apply_case()
      self:apply_padding()
      self:apply_highlights(default_highlight)
      self:apply_section_separators()
      self:apply_separator()
    end
    return self.status
  end,
}

return Component
