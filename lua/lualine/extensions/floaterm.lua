-- MIT license, see LICENSE for more details.
-- Extension for floaterm.nvim

-- based from here https://github.com/voldikss/vim-floaterm/issues/224#issuecomment-755233112
local vim_func =
[[
function! FloatermStatus() abort
  let buffers = floaterm#buflist#gather()
  let cnt = len(buffers)
  if cnt == 0 | return '' | endif
  let cur = floaterm#buflist#curr()
  let idx = index(buffers, cur) + 1
  let name = floaterm#config#get(cur, 'name')

  if empty(name)
      return printf('floaterm %s/%s', idx, cnt)
  endif

  return printf('floaterm (%s) %s/%s', name, idx, cnt)
endfunction

echo FloatermStatus()
]]

local function floaterm_statusline() return vim.api.nvim_exec(vim_func, true) end

local M = {}

M.sections = {lualine_a = {floaterm_statusline}}

M.filetypes = {'floaterm'}

return M
