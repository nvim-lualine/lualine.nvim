local M = {}

local short_path = function()
    local path = require('drex.utils').get_root_path(0)
    return vim.fn.fnamemodify(path, ':~')
end

local clipboard_entries = function()
    return vim.tbl_count(require('drex.actions').clipboard)
end

M.sections = {
  lualine_a = { short_path },
  lualine_z = { clipboard_entries },
}

M.filetypes = {
  'drex',
}

return M
