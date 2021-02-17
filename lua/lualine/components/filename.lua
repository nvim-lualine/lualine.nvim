-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local function filename(options)
  -- setting defaults
  local file_status, shorten, full_path = true, true, false
  if options.file_status  ~= nil then file_status = options.file_status end
  if options.shorten ~= nil then shorten = options.shorten end
  if options.full_path  ~= nil then full_path = options.full_path end

  return function()
    local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
    local data = vim.api.nvim_buf_call(bufnr, function()
      if not full_path then
        return vim.fn.expand('%:t')
      elseif shorten then
        return vim.fn.expand('%')
      else
        return vim.fn.expand('%:p')
      end
    end)
    if data == '' then
      data = '[No Name]'
    elseif vim.fn.winwidth(0) <= 84 or #data > 40 then
      data = vim.fn.pathshorten(data)
    end

    if file_status then
      if vim.bo[bufnr].modified then data = data .. "[+]"
      elseif not vim.bo[bufnr].modifiable then data = data .. "[-]" end
    end
    return data
  end
end

return { init = function(options) return filename(options) end }
