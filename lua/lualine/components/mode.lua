local function mode()
  local mode_map = {
    ['__'] = '------',
    ['n']  = 'NORMAL',
    ['no']  = 'O-PENDING',
    ['nov']  = 'O-PENDING',
    ['noV']  = 'O-PENDING',
    ['no']  = 'O-PENDING',
    ['niI']  = 'NORMAL',
    ['niR']  = 'NORMAL',
    ['niV']  = 'NORMAL',
    ['v']  = 'VISUAL',
    ['V']  = 'V-LINE',
    [''] = 'V-BLOCK',
    ['s']  = 'SELECT',
    ['S']  = 'S-LINE',
    ['']  = 'S-BLOCK',
    ['i']  = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['R']  = 'REPLACE',
    ['Rc'] = 'REPLACE',
    ['Rv'] = 'V-REPLACE',
    ['Rx'] = 'REPLACE',
    ['c']  = 'COMMAND',
    ['cv']  = 'EX',
    ['ce']  = 'EX',
    ['r']  = 'REPLACE',
    ['rm']  = 'MORE',
    ['r?']  = 'CONFIRM',
    ['!']  = 'SHELL',
    ['t']  = 'TERMINAL',
  }
  local function get_mode()
    local mode_code = vim.api.nvim_get_mode().mode
    if mode_map[mode_code] == nil then return mode_code end
    return mode_map[mode_code]
  end
  return get_mode()
end

return mode
