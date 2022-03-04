local Window = require('lualine.components.buffers.buffer'):extend()

---intialize a new buffer from opts
---@param opts table
function Window:init(opts)
  Window.super.init(self, opts)

  self.winnr = opts.winnr
end

function Window:is_current()
  return vim.api.nvim_get_current_win() == self.winnr
end

return Window
