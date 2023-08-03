local M = {}

local function get_trouble_mode()
  local opts = require('trouble.config').options

  local words = vim.split(opts.mode, '[%W]')
  for i, word in ipairs(words) do
    words[i] = word:sub(1, 1):upper() .. word:sub(2)
  end

  return table.concat(words, ' ')
end

M.sections = {
  lualine_a = {
    get_trouble_mode,
  },
}

M.filetypes = { 'Trouble' }

return M
