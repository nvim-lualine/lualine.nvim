-- MIT license, see LICENSE for more details.
-- Extension for avante.nvim

local M = {}

local function ft_info()
  local ft = vim.opt_local.filetype:get()
  if ft == 'Avante' then
    return 'Output'
  elseif ft == 'AvanteInput' then
    return require('lualine.utils.mode').get_mode()
  elseif ft == 'AvanteSelectedCode' then
    local max_shown = vim.api.nvim_win_get_height(0)
    local avante_ok, avante_config = pcall(require, 'avante.config')
    if avante_ok and avante_config.windows.sidebar_header.enabled then
      max_shown = max_shown - 1
    end
    local num_lines = vim.api.nvim_buf_line_count(0)
    return string.format('Code Fragment: %s%d lines', max_shown < num_lines and (max_shown .. '/') or '', num_lines)
  elseif ft == 'AvanteSelectedFiles' then
    return 'Total Files: ' .. vim.api.nvim_buf_line_count(0)
  elseif ft == 'AvanteTodos' then
    local todos = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local completed = vim.iter(todos):fold(0, function(counter, todo)
      if todo:sub(1, 3) == '[x]' then
        counter = counter + 1
      end
      return counter
    end)
    return string.format('Todos: %d/%d', completed, #todos)
  end
end

M.sections = { lualine_a = { ft_info } }

M.filetypes = { 'Avante', 'AvanteInput', 'AvanteSelectedCode', 'AvanteSelectedFiles', 'AvanteTodos' }

return M
