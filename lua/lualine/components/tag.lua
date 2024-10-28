local M = require('lualine.component'):extend()

-- Initializer
function M:init(options)
  -- Run super()
  M.super.init(self, options)
end

-- Function that runs every time statusline is updated
function M:update_status()
  return vim.fn.system("git tag --points-at | tr -d '\n'")
end

return M
