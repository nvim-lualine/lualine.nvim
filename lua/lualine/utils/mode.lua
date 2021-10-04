-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local Mode = {}
-- stylua: ignore
Mode.map = {
  ['n']    = 'NORMAL',
  ['no']   = 'O-PENDING',
  ['nov']  = 'O-PENDING',
  ['noV']  = 'O-PENDING',
  ['no'] = 'O-PENDING',
  ['niI']  = 'NORMAL',
  ['niR']  = 'NORMAL',
  ['niV']  = 'NORMAL',
  ['v']    = 'VISUAL',
  ['vs']   = 'VISUAL',
  ['V']    = 'V-LINE',
  ['Vs']   = 'V-LINE',
  ['']   = 'V-BLOCK',
  ['s']  = 'V-BLOCK',
  ['s']    = 'SELECT',
  ['S']    = 'S-LINE',
  ['']   = 'S-BLOCK',
  ['i']    = 'INSERT',
  ['ic']   = 'INSERT',
  ['ix']   = 'INSERT',
  ['R']    = 'REPLACE',
  ['Rc']   = 'REPLACE',
  ['Rx']   = 'REPLACE',
  ['Rv']   = 'V-REPLACE',
  ['Rvc']  = 'V-REPLACE',
  ['Rvx']  = 'V-REPLACE',
  ['c']    = 'COMMAND',
  ['cv']   = 'EX',
  ['ce']   = 'EX',
  ['r']    = 'REPLACE',
  ['rm']   = 'MORE',
  ['r?']   = 'CONFIRM',
  ['!']    = 'SHELL',
  ['t']    = 'TERMINAL',
}

function Mode.get_mode()
  local mode_code = vim.api.nvim_get_mode().mode
  if Mode.map[mode_code] == nil then
    return mode_code
  end
  return Mode.map[mode_code]
end

return Mode
