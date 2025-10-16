local Window = require('lualine.components.buffers.buffer'):extend()

---initialize a new buffer from opts
---@param opts table
function Window:init(opts)
  assert(opts.winnr, 'Cannot create Window without winnr')
  opts.bufnr = vim.api.nvim_win_get_buf(opts.winnr)

  Window.super.init(self, opts)

  self.winnr = opts.winnr
  self.win_number = vim.api.nvim_win_get_number(self.winnr)
end

function Window:is_current()
  return vim.api.nvim_get_current_win() == self.winnr
end

function Window:apply_mode(name)
  local icon, extra_len = self:render_icon()

  local str
  if self.options.mode == 0 then
    str = string.format('%s%s%s', icon, name, self.modified_icon)
  elseif self.options.mode == 1 then
    str = string.format('%s %s%s', self.win_number, icon, self.modified_icon)
  else
    str = string.format('%s %s%s%s', self.win_number, icon, name, self.modified_icon)
  end

  local len = vim.fn.strchars(str) - extra_len
  return str, len
end

function Window:configure_mouse_click(name)
  return string.format('%%%s@LualineSwitchWindow@%s%%T', self.win_number, name)
end

return Window
