-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()

local modules = require('lualine_require').lazy_require {
  utils = 'lualine.utils.utils',
  harpoon_mark = 'harpoon.mark'
}

local mark_cache = {}
local changes = 0

M.init = function(self, options)
  M.super.init(self, options)
  if not self.options.icon then
    self.options.icon = 'ﯠ' -- fbe0
  end
end

M.update_status = function(_, is_focused)
  mark = modules.harpoon_mark.get_current_index()
  if mark then
    return modules.utils.stl_escape(tostring(mark))
  else
    return ''
  end
end

return M
