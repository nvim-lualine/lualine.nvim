local M = {}

M.sections = {
  lualine_a = {
    function()
      return vim.fn['ctrlspace#context#Configuration']().Symbols.CS
    end,
  },
  lualine_b = { 'ctrlspace#api#StatuslineModeSegment' },
  lualine_y = { 'ctrlspace#api#StatuslineTabSegment' },
  lualine_z = {
    function()
      return 'CtrlSpace'
    end,
  },
}

M.filetypes = { 'ctrlspace' }

return M
