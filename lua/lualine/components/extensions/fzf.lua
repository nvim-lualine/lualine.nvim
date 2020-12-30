local function fzfStatusline()
  vim.cmd([[hi clear fzf1]])
  vim.cmd([[hi link fzf1 lualine_a_normal]])
  vim.cmd([[hi clear fzf2]])
  vim.cmd([[hi link fzf2 lualine_c_normal]])
  return ([[%#fzf1# FZF %#fzf2#]])

end

local function loadExtension()
  _G.fzfStatusline = fzfStatusline
  vim.cmd(([[autocmd! User FzfStatusLine setlocal statusline=%!v:lua.fzfStatusline()]]))
end

return {
  loadExtension = loadExtension
}
