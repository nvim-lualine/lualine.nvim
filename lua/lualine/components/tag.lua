local M = require('lualine.component'):extend()

-- Initializer
function M:init(options)
  -- Run super()
  M.super.init(self, options)
end

-- Function that runs every time statusline is updated
function M:update_status()
  local tag = vim.fn.system("git tag --points-at | tr -d '\n'")
  if string.find(tag, "error: ") or string.find(tag, "fatal: ") then
    return ''
  end
  return tag
end

return M
