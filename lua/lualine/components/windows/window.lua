local Window = require('lualine.components.buffers.buffer'):extend()

---intialize a new buffer from opts
---@param opts table
function Window:init(opts)
  Window.super.init(self, opts)

  self.winnr = opts.winnr
  self.win_number = vim.api.nvim_win_get_number(self.winnr)
end

function Window:is_current()
  return vim.api.nvim_get_current_win() == self.winnr
end

function Window:apply_mode(name)
  if self.options.mode == 0 then
    return string.format('%s%s%s', self.icon, name, self.modified_icon)
  end

  if self.options.mode == 1 then
    return string.format('%s %s%s', self.win_number, self.icon, self.modified_icon)
  end

  return string.format('%s %s%s%s', self.win_number, self.icon, name, self.modified_icon)
end

return Window
