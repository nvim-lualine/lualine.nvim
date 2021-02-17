-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local function fzf_statusline()
  vim.cmd([[hi clear fzf1]])
  vim.cmd([[hi link fzf1 lualine_a_normal]])
  vim.cmd([[hi clear fzf2]])
  vim.cmd([[hi link fzf2 lualine_c_normal]])
  return ([[%#fzf1# FZF %#fzf2#]])

end

local function load_extension()
  _G.fzf_statusline = fzf_statusline
  vim.cmd(([[autocmd! User FzfStatusLine setlocal statusline=%!v:lua.fzf_statusline()]]))
end

return {
  load_extension = load_extension
}
