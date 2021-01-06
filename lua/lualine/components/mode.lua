local function mode()
  local mode_map = {
    ['__'] = '------',
    ['n']  = 'NORMAL',
    ['i']  = 'INSERT',
    ['v']  = 'VISUAL',
    ['V']  = 'V-LINE',
    [''] = 'V-BLOCK',
    ['R']  = 'REPLACE',
    ['r']  = 'REPLACE',
    ['Rv'] = 'V-REPLACE',
    ['c']  = 'COMMAND',
    ['t']  = 'TERMINAL',
    ['s']  = 'SELECT',
  }
  return mode_map[vim.fn.mode()]
end

return mode
