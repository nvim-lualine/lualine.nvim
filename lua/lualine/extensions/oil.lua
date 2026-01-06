-- Extension for oil.nvim

local M = {}

local config = require('lualine.config')

M.sections = vim.deepcopy(config.get_config().sections)
M.sections.lualine_c = {
    function()
        local ok, oil = pcall(require, 'oil')
        if ok then
            return vim.fn.fnamemodify(oil.get_current_dir(), ':~')
        else
            return ''
        end
    end,
}

M.filetypes = { 'oil' }

return M
