local M = require('lualine.component'):extend()

local default_options = {
  maxcount = 999,
  timeout = 500,
}

-- Initializer
function M:init(options)
  -- Run super()
  M.super.init(self, options)
  -- Apply default options
  self.options = vim.tbl_extend('keep', self.options or {}, default_options)
end

-- Function that runs every time statusline is updated
function M:update_status()
  if vim.v.hlsearch == 0 then
    return ''
  end

  local ok, result = pcall(vim.fn.searchcount, { maxcount = self.options.maxcount, timeout = self.options.timeout })
  if not ok or next(result) == nil then
    return ''
  end

  local denominator = math.min(result.total, result.maxcount)
  return string.format('[%d/%d]', result.current, denominator)
end

return M
