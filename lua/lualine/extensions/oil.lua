-- Extension for oil.nvim

local ok, oil = pcall(require, "oil")
if not ok then
  return ""
end

local M = {}

M.sections = {
  lualine_a = {
    function()
      return vim.fn.fnamemodify(oil.get_current_dir(), ':~')
    end,
  },
}

M.filetypes = { "oil" }

return M
