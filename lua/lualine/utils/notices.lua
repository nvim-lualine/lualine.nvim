-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

-- To provide notices for user
local M = {}
local notices = {}
local persistent_notices = {}

---append new notice
---@param notice string|table table is a list of strings
function M.add_notice(notice)
  if type(notice) == 'string' then
    notice = vim.split(notice, '\n')
  end
  if notice[#notice] ~= '' then
    notice[#notice + 1] = ''
  end
  table.insert(notices, notice)
end

---appends persistent notice. These don't get cleared on setup
---@param notice string|table table is a list of strings
function M.add_persistent_notice(notice)
  if type(notice) == 'string' then
    notice = vim.split(notice, '\n')
  end
  if not vim.tbl_contains(persistent_notices, notice) then
    table.insert(persistent_notices, notice)
  end
end

---show setup :LuaLineNotices and show notification about error when there
---are notices available
local notify_done = false
function M.notice_message_startup()
  notify_done = false
  vim.defer_fn(function()
    if notify_done then
      return
    end
    if #notices > 0 or #persistent_notices > 0 then
      vim.cmd('command! -nargs=0 LualineNotices lua require"lualine.utils.notices".show_notices()')
      vim.notify(
        'lualine: There are some issues with your config. Run :LualineNotices for details',
        vim.log.levels.WARN,
        {}
      )
    end
    notify_done = true
  end, 2000)
end

---create notice view
function M.show_notices()
  vim.cmd('silent! keepalt split')

  local winid = vim.api.nvim_get_current_win()
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
    vim.notify('Lualine Notices is already open in another buffer', vim.log.levels.ERROR, {})
    vim.cmd('normal q')
    return
  end
  local notice = vim.tbl_flatten(persistent_notices)
  notice = vim.list_extend(notice, vim.tbl_flatten(notices))
  vim.fn.appendbufline(bufnr, 0, notice)

  vim.fn.deletebufline(bufnr, #notice, vim.fn.line('$'))
  vim.api.nvim_win_set_cursor(winid, { 1, 0 })
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].modifiable = false
end

function M.clear_notices()
  notices = {}
end

return M
