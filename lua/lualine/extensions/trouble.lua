local M = {}

---Format mode, eg: lsp_document_symbols -> Lsp Document Symbols
---@param mode string
---@return string
local function _format_mode(mode)
  local words = vim.split(mode, '[%W]')
  for i, word in ipairs(words) do
    words[i] = word:sub(1, 1):upper() .. word:sub(2)
  end

  return table.concat(words, ' ')
end

local function get_trouble_mode()
  local opts = require('trouble.config').options
  if opts ~= nil and opts.mode ~= nil then
    return _format_mode(opts.mode)
  end

  local win = vim.api.nvim_get_current_win()
  if vim.w[win] ~= nil then
    local trouble = vim.w[win].trouble
    if trouble ~= nil and trouble.mode ~= nil then
      return _format_mode(trouble.mode)
    end
  end

  return ''
end

M.sections = {
  lualine_a = {
    get_trouble_mode,
  },
}

M.filetypes = { 'trouble', 'Trouble' }

return M
