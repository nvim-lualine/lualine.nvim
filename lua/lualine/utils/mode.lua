-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local Mode = {}
local Msgstr = require('lualine.langMSG').Msgstr

-- stylua: ignore
Mode.map = {
  ['n']      = Msgstr('NORMAL'),
  ['no']     = Msgstr('O-PENDING'),
  ['nov']    = Msgstr('O-PENDING'),
  ['noV']    = Msgstr('O-PENDING'),
  ['no\22'] = Msgstr('O-PENDING'),
  ['niI']    = Msgstr('NORMAL'),
  ['niR']    = Msgstr('NORMAL'),
  ['niV']    = Msgstr('NORMAL'),
  ['nt']     = Msgstr('NORMAL'),
  ['ntT']    = Msgstr('NORMAL'),
  ['v']      = Msgstr('VISUAL'),
  ['vs']     = Msgstr('VISUAL'),
  ['V']      = Msgstr('V-LINE'),
  ['Vs']     = Msgstr('V-LINE'),
  ['\22']   = Msgstr('V-BLOCK'),
  ['\22s']  = Msgstr('V-BLOCK'),
  ['s']      = Msgstr('SELECT'),
  ['S']      = Msgstr('S-LINE'),
  ['\19']   = Msgstr('S-BLOCK'),
  ['i']      = Msgstr('INSERT'),
  ['ic']     = Msgstr('INSERT'),
  ['ix']     = Msgstr('INSERT'),
  ['R']      = Msgstr('REPLACE'),
  ['Rc']     = Msgstr('REPLACE'),
  ['Rx']     = Msgstr('REPLACE'),
  ['Rv']     = Msgstr('V-REPLACE'),
  ['Rvc']    = Msgstr('V-REPLACE'),
  ['Rvx']    = Msgstr('V-REPLACE'),
  ['c']      = Msgstr('COMMAND'),
  ['cv']     = Msgstr('EX'),
  ['ce']     = Msgstr('EX'),
  ['r']      = Msgstr('REPLACE'),
  ['rm']     = Msgstr('MORE'),
  ['r?']     = Msgstr('CONFIRM'),
  ['!']      = Msgstr('SHELL'),
  ['t']      = Msgstr('TERMINAL')
}

---@return string current mode name
function Mode.get_mode()
  local mode_code = vim.api.nvim_get_mode().mode
  if Mode.map[mode_code] == nil then
    return mode_code
  end
  return Mode.map[mode_code]
end

return Mode
