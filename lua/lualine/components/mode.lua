local function Mode()
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
  }
  return mode_map[vim.fn.mode()]
end

return Mode
