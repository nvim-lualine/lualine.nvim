local Window = require('lualine.components.windows.window')
local M = require('lualine.components.buffers'):extend()

local default_options = {
  disabled_filetypes = {},
  disabled_buftypes = { 'quickfix', 'prompt' }
}

function M:init(options)
  M.super.init(self, options)

  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
end

function M:new_buffer(bufnr, winnr)
  return Window:new({
    bufnr = bufnr,
    winnr = winnr,
    options = self.options,
    highlights = self.highlights,
  })
end

--- Override to only return buffers shown in the windows of the current tab
function M:buffers()
  local tabnr = vim.api.nvim_get_current_tabpage()
  local buffers = {}

  for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
    if not self:should_hide(winnr) then
      buffers[#buffers + 1] = self:new_buffer(vim.api.nvim_win_get_buf(winnr), winnr)
    end
  end

  return buffers
end

function M:should_hide(winnr)
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
  local is_filetype_disabled = vim.tbl_contains(self.options.disabled_filetypes, filetype)
  local is_buftype_disabled = vim.tbl_contains(self.options.disabled_buftypes, buftype)
  local is_listed = vim.api.nvim_buf_get_option(bufnr, 'buflisted')

  return not is_listed or is_buftype_disabled or is_filetype_disabled
end

return M
