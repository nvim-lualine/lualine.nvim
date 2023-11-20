-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local Mode = {}

-- stylua: ignore
Mode.map = {
   ['n']     = 'NORMAL',
   ['no']    = 'O-PENDING',
   ['nov']   = 'O-PENDING',
   ['noV']   = 'O-PENDING',
   ['no\22'] = 'O-PENDING',
   ['niI']   = 'NORMAL',
   ['niR']   = 'NORMAL',
   ['niV']   = 'NORMAL',
   ['nt']    = 'NORMAL',
   ['ntT']   = 'NORMAL',
   ['v']     = 'VISUAL',
   ['vs']    = 'VISUAL',
   ['V']     = 'V-LINE',
   ['Vs']    = 'V-LINE',
   ['\22']   = 'V-BLOCK',
   ['\22s']  = 'V-BLOCK',
   ['s']     = 'SELECT',
   ['S']     = 'S-LINE',
   ['\19']   = 'S-BLOCK',
   ['i']     = 'INSERT',
   ['ic']    = 'INSERT',
   ['ix']    = 'INSERT',
   ['R']     = 'REPLACE',
   ['Rc']    = 'REPLACE',
   ['Rx']    = 'REPLACE',
   ['Rv']    = 'V-REPLACE',
   ['Rvc']   = 'V-REPLACE',
   ['Rvx']   = 'V-REPLACE',
   ['c']     = 'COMMAND',
   ['cv']    = 'EX',
   ['ce']    = 'EX',
   ['r']     = 'REPLACE',
   ['rm']    = 'MORE',
   ['r?']    = 'CONFIRM',
   ['!']     = 'SHELL',
   ['t']     = 'TERMINAL',
}

local last_mode = 'NORMAL'
vim.api.nvim_create_autocmd({ 'CmdlineEnter' }, {
  pattern = { '*' },
  callback = function()
    -- it's 1 when a : command is silent
    if vim.fn.getcmdscreenpos() ~= 1 then
      last_mode = Mode.map['c']
    end
  end,
})

---@return string current mode name
function Mode.get_mode()
  local mode_code = vim.api.nvim_get_mode().mode
  local mode = Mode.map[mode_code]
  -- if a mapping is not done don't react to mode changes
  if vim.fn.getchar(1) ~= 0 then
    return last_mode
  end
  if mode == nil then
    mode = mode_code
  end
  last_mode = mode
  return mode
end

return Mode
