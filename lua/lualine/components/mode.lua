local function mode()
  local mode_map = {
    ['__'] = '------',
    ['n']  = 'NORMAL',
    ['i']  = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['v']  = 'VISUAL',
    ['V']  = 'V-LINE',
    [''] = 'V-BLOCK',
    ['R']  = 'REPLACE',
    ['r']  = 'REPLACE',
    ['rc'] = 'REPLACE',
    ['rx'] = 'REPLACE',
    ['Rv'] = 'V-REPLACE',
    ['c']  = 'COMMAND',
    ['t']  = 'TERMINAL',
    ['s']  = 'SELECT',
  }
  local function get_mode()
    local mode_code = vim.api.nvim_get_mode().mode
    if mode_map[mode_code] == nil then return mode_code end
    return mode_map[mode_code]
  end
  return get_mode()
end

return mode
