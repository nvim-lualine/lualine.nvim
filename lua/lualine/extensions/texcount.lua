local M = {}

local n_words = '-'
local function n_words_component()
  return n_words .. ' words'
end

M.filetypes = { 'tex' }
M.sections = require('lualine').get_config().sections
local orignal_sections = require('lualine').get_config().sections.lualine_x
M.sections.lualine_x = vim.tbl_extend('keep', { n_words_component }, orignal_sections)

local texcount_group = vim.api.nvim_create_augroup('TexCount', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufWinEnter' }, {
  pattern = '*.tex',
  group = texcount_group,
  callback = function()
    n_words = vim.fn.system('texcount -1 -sum -merge ' .. vim.fn.shellescape(vim.fn.expand('%:p'))):gsub('%s+', '')
  end,
})

return M
