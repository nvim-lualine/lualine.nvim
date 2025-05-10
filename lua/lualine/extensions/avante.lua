-- MIT license, see LICENSE for more details.
-- Extension for avante.nvim
local M = {}

local function ft_info()
  local ft = vim.opt_local.filetype:get()
  if ft == 'Avante' then
    return 'Output'
  elseif ft == 'AvanteInput' then
    return require('lualine.utils.mode').get_mode()
  elseif ft == 'AvanteSelectedFiles' then
    return 'Total Files: ' .. vim.api.nvim_buf_line_count(0)
  end
end

M.sections = { lualine_a = { ft_info } }

M.filetypes = { 'Avante', 'AvanteInput', 'AvanteSelectedFiles' }

return M
