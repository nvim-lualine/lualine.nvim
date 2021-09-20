-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

-- To provide notices for user
local M = {}
local notices = {}
local persistent_notices = {}

function M.add_notice(notice)
  if type(notice) == 'string' then
    notice = vim.split(notice, '\n')
  end
  table.insert(notices, notice)
end

function M.add_persistent_notice(notice)
  if type(notice) == 'string' then
    notice = vim.split(notice, '\n')
  end
  if not vim.tbl_contains(persistent_notices, notice) then
    table.insert(persistent_notices, notice)
  end
end

function M.notice_message_startup()
  if #notices > 0 or #persistent_notices then
    vim.cmd 'command! -nargs=0 LualineNotices lua require"lualine.utils.notices".show_notices()'
    vim.schedule(function()
      vim.notify(
        'lualine: There are some issues with your config. Run :LualineNotices for details',
        vim.log.levels.WARN,
        {}
      )
    end)
  end
end

function M.show_notices()
  vim.cmd [[
  :silent! new
  :silent! setl ft=markdown bt=nofile nobuflisted bh=wipe
  :silent! nnoremap <silent><buffer> q <cmd>bd<cr>
  :silent! normal ggdG
  ]]
  local ok, _ = pcall(vim.api.nvim_buf_set_name, 0, 'Lualine Notices')
  if not ok then
    vim.notify('Lualine Notices is already open in another window', vim.log.levels.ERROR, {})
    vim.cmd 'normal q'
    return
  end
  local notice = vim.tbl_flatten(persistent_notices)
  notice = vim.list_extend(notice, vim.tbl_flatten(notices))
  vim.fn.append(0, notice)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

function M.clear_notices()
  notices = {}
end

return M
