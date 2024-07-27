local function executable()
  local name = vim.api.nvim_buf_get_name(0)
  local match = string.match(vim.split(name, ' ')[1], 'term:.*:(%a+)')
  return match ~= nil and match or vim.fn.fnamemodify(vim.env.SHELL, ':t')
end

local function term_title()
  return vim.b.term_title
end

local M = {}

M.sections = {
  lualine_a = { function() return 'TERMINAL' end },
  lualine_b = { executable },
  lualine_c = { term_title },
}

function M.init()
  M.term_icon = nil
  local has_icons, webdevicons = pcall(require, 'nvim-web-devicons')
  if has_icons then
    M.term_icon = webdevicons.get_icon('zsh')
    M.sections.lualine_y = { function() return M.term_icon end }
  end
end

M.buftypes = { 'terminal' }

return M
