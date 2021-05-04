local highlight = require 'lualine.highlight'

-- Used to provide a unique id for each component
local component_no = 1

-- Here we're manupulation the require() cache so when we
-- require('lualine.component.components') it will return this table
-- It's hacky but package.loaded is documented in lua docs so from
-- standereds point of view we're good ]. I think it's better than
-- modifiying global state
package.loaded['lualine.component.components'] = {}
local components = package.loaded['lualine.component.components']

local Component = {
  -- Creates a new component
  new = function(self, options, child)
    local new_component = {}
    new_component.options = options
    new_component._parent = child or self
    setmetatable(new_component, {__index = new_component._parent})
    -- Operation that are required for creating new components but not for inheritence
    if options ~= nil then
      component_no = component_no + 1
      if not options.component_name then
        new_component.options.component_name = tostring(component_no)
      end
      new_component.component_no = component_no
      components[component_no] = new_component
      new_component:set_separator()
      new_component:create_option_highlights()
    end
    return new_component
  end,

  set_separator = function(self)
    if type(self.options.separator) ~= 'string' then
      if self.options.component_separators then
        if self.options.self.section < 'lualine_x' then
          self.options.separator = self.options.component_separators[1]
        else
          self.options.separator = self.options.component_separators[2]
        end
      end
    end
  end,

  create_option_highlights = function(self)
    -- set custom highlights
    if type(self.options.color) == 'table' then
      self.options.color_highlight = highlight.create_component_highlight_group(
                                         self.options.color,
                                         self.options.component_name,
                                         self.options)
    elseif type(self.options.color) == 'string' then
      self.options.color_highlight_link = self.options.color
    end
  end,

  -- set upper or lower case
  apply_case = function(self)
    -- Donn't work on components that emit vim statusline escaped chars
    if self.status:find('%%') and not self.status:find('%%%%') then return end
    if self.options.upper == true then
      self.status = self.status:upper()
    elseif self.options.lower == true then
      self.status = self.status:lower()
    end
  end,

  -- Adds spaces to left and right of a component
  apply_padding = function(self)
    local l_padding = (self.options.left_padding or self.options.padding or 1)
    local r_padding = (self.options.right_padding or self.options.padding or 1)
    if l_padding then
      if self.status:find('%%#.*#') == 1 then
        -- When component has changed the highlight at begining
        -- we will add the padding after the highlight
        local pre_highlight =
            vim.fn.matchlist(self.status, [[\(%#.\{-\}#\)]])[2]
        self.status = pre_highlight .. string.rep(' ', l_padding) ..
                          self.status:sub(#pre_highlight + 1, #self.status)
      else
        self.status = string.rep(' ', l_padding) .. self.status
      end
    end
    if r_padding then self.status = self.status .. string.rep(' ', r_padding) end
  end,

  -- Applies custom highlights for component
  apply_highlights = function(self, default_highlight)
    if self.options.color_highlight then
      self.status = highlight.component_format_highlight(
                        self.options.color_highlight) .. self.status
    elseif self.options.color_highlight_link then
      self.status = '%#' .. self.options.color_highlight_link .. '#' ..
                        self.status
    end
    self.status = self.status .. default_highlight
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
    if self.options.separator and #self.options.separator > 0 then
      self.status = self.status .. self.options.separator
      self.applied_separator = self.options.separator
    end
  end,

  strip_separator = function(self, default_highlight)
    if self.status:find('%%{') == 1 then default_highlight = '' end
    if not default_highlight then default_highlight = '' end
    if not self.applied_separator then self.applied_separator = '' end
    self.status = self.status:sub(1, (#self.status -
                                      (#self.applied_separator +
                                          #default_highlight)))
    self.applied_separator = nil
    return self.status
  end,

  -- variable to store component output for manupulation
  status = '',
  -- Actual function the updates a component . Must be overwritten with component functionality
  -- luacheck: push no unused args
  update_status = function(self) end,
  -- luacheck: pop

  -- Driver code of the class
  draw = function(self, default_highlight, statusline_inactive)
    -- Check if we are in in inactive state and need to enable inactive_eval
    -- for this compoennt
    if self.inactive_eval and not statusline_inactive and vim.g.statusline_winid ~=
        vim.fn.win_getid() then
      -- In that case we'll return a evaluator
      self.status = '%' .. string.format(
                        '{v:lua.require\'lualine.utils.utils\'.lualine_eval(%s,\'\',v:true)}',
                        tostring(self.component_no))
      -- Need to apply the highlights early as %{} escapes % :(
      -- I'm not sure if it's a good idea. But don't have an option.
      self:apply_highlights(default_highlight)
      return self.status
    end
    self.status = ''
    if self.options.condition ~= nil and self.options.condition() ~= true then
      return self.status
    end
    local status = self:update_status()
    if self.options.format then status = self.options.format(status or '') end
    if type(status) == 'string' and #status > 0 then
      self.status = status
      self:apply_icon()
      self:apply_case()
      self:apply_padding()
      if not statusline_inactive then
        -- incase of inactive eval highlight hasbeen pre applied
        self:apply_highlights(default_highlight)
      end
      if not (statusline_inactive and self.last_conponent) then
        self:apply_separator()
      end
    end
    return self.status
  end
}

return Component
