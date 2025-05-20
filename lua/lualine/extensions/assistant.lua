-- lualine extension for assistant.nvim

local ok, assistant = pcall(require, 'assistant')

if not ok then
  return nil
end

local M = {}

M.sections = {
  lualine_a = {
    function()
      return 'Assistant'
    end,
  },
  lualine_b = {
    function()
      return vim.bo.filetype:match('%w+.(%w+)')
    end,
  },
  lualine_c = {
    function()
      return assistant.status()[vim.bo.filetype:match('%w+.(%w+)')] or ''
    end,
  },
}

M.filetypes = {
  'assistant-panel',
  'assistant-previewer',
  'assistant-picker',
  'assistant-dialog',
  'assistant-patcher',
}

return M
