-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
--
local function is_loclist()
  return vim.fn.getloclist(0, { filewinid = 1 }).filewinid ~= 0
end

local function label()
  return is_loclist() and 'Location List' or 'Quickfix List'
end

local function title()
  if is_loclist() then
    return vim.fn.getloclist(0, { title = 0 }).title
  end
  return vim.fn.getqflist({ title = 0 }).title
end

local qf_colours = {
  ll = vim.api.nvim_get_hl_by_name('Constant', false).foreground,
  qf = vim.api.nvim_get_hl_by_name('Identifier', false).foreground,
}

local M = {}

function M.init()
  -- Make sure ft wf doesn't create a custom statusline
  vim.g.qf_disable_statusline = true
end

M.sections = {
  lualine_a = {
    {
      label,
      color = function()
        return is_loclist() and { bg = qf_colours['ll'] } or { bg = qf_colours['qf'] }
      end,
    },
  },
  lualine_b = { title },
  lualine_z = { 'location' },
}

M.filetypes = { 'qf' }

return M
