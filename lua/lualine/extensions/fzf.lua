--[[
lualine extension for fzf filetypes:
works with both https://github.com/junegunn/fzf.vim and https://github.com/ibhagwan/fzf-lua

-- fzf-lua must be set-up in split mode
]]

local fzf_lua, _ = pcall(require, 'fzf-lua')

local function fzf_picker()
  if not fzf_lua then
    return ''
  end

  local info_string = vim.inspect(require('fzf-lua').get_info()['fnc'])
  return info_string:gsub('"', '')
end

local function fzf_element()
  if not fzf_lua then
    return ''
  end

  local fzf = require('fzf-lua')
  local selected = fzf.get_info().selected
  return fzf.path.entry_to_file(selected).path
end

local function fzf_statusline()
  return 'FZF'
end

local M = {}

M.sections = {
  lualine_a = { fzf_statusline },
  lualine_y = { fzf_element },
  lualine_z = { fzf_picker },
}

M.filetypes = { 'fzf' }

return M
