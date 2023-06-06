local M = {}

-- Set the initial state of n_words to '-'
local n_words = '-'

-- Define the functions that will be used in the lualine section and autocmd
local function n_words_component()
  return n_words .. ' words'
end

local function update_n_words()
  n_words = vim.fn.system('texcount -1 -sum -merge ' .. vim.fn.shellescape(vim.fn.expand('%:p'))):gsub('%s+', '')
end

-- Copy the original sections
M.sections = require('lualine').get_config().sections

-- Copy the original lualine_x
local orignal_lualine_x = require('lualine').get_config().sections.lualine_x

-- Merge a new table containing the new component and the original lualine_x
M.sections.lualine_x = vim.tbl_extend('keep', { n_words_component }, orignal_lualine_x)

-- Create a autogroup that clears itself
local texcount_group = vim.api.nvim_create_augroup('TexCount', { clear = true })

-- Create an autocmd that updates the n_words variable when the user opens the .tex file and at every it gets writen
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufWinEnter' }, {
  pattern = '*.tex',
  group = texcount_group,
  callback = update_n_words,
})

-- Set the filetype of the extension
M.filetypes = { 'tex' }

return M
