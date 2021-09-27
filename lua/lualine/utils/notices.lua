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
  vim.cmd 'silent! keepalt split'

  local winid = vim.fn.win_getid()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(winid, bufnr)

  vim.wo[winid].winfixheight = true
  vim.wo[winid].winfixwidth = true
  vim.wo[winid].number = false
  vim.wo[winid].foldcolumn = '0'
  vim.wo[winid].relativenumber = false
  vim.wo[winid].signcolumn = 'no'
  vim.bo[bufnr].filetype = 'markdown'

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '<Cmd>bd<CR>', { noremap = true, silent = true })

  local ok, _ = pcall(vim.api.nvim_buf_set_name, 0, 'Lualine Notices')
  if not ok then
    vim.notify('Lualine Notices is already open in another window', vim.log.levels.ERROR, {})
    vim.cmd 'normal q'
    return
  end
  local notice = vim.tbl_flatten(persistent_notices)
  notice = vim.list_extend(notice, vim.tbl_flatten(notices))
  vim.fn.appendbufline(bufnr, 0, notice)

  vim.fn.deletebufline(bufnr, #notice, vim.fn.line '$')
  vim.api.nvim_win_set_cursor(winid, { 1, 0 })
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].modifiable = false
end

function M.clear_notices()
  notices = {}
end

return M
