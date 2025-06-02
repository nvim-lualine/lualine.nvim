local M = {}

---@param file string
---@param bufnr integer
---@param buftype string
---@param filetype string
---@return string|nil
function M.file(file, bufnr, buftype, filetype)
  local has_miniicons, miniicons = pcall(require, 'mini.icons')
  if has_miniicons and _G.MiniIcons then
    return miniicons.get('file', file)
  end

  local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
  if has_devicons then
    if filetype == 'TelescopePrompt' then
      return devicons.get_icon('telescope')
    elseif filetype == 'fugitive' then
      return devicons.get_icon('git')
    elseif filetype == 'vimwiki' then
      return devicons.get_icon('markdown')
    elseif buftype == 'terminal' then
      return devicons.get_icon('zsh')
    else
      return devicons.get_icon(file, vim.fn.expand('#' .. bufnr .. ':e'))
    end
  end

  return nil
end

---@return string|nil, string|nil
function M.filetype()
  local has_miniicons, miniicons = pcall(require, 'mini.icons')
  if has_miniicons and _G.MiniIcons then
    return miniicons.get('filetype', vim.bo.filetype)
  end

  local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
  if has_devicons then
    local icon, highlight = devicons.get_icon(vim.fn.expand('%:t'))
    if not icon then
      icon, highlight = devicons.get_icon_by_filetype(vim.bo.filetype)
    end
    if not icon and not highlight then
      icon, highlight = '', 'DevIconDefault'
    end
    return icon, highlight
  end

  if vim.fn.exists('*WebDevIconsGetFileTypeSymbol') ~= 0 then
    return vim.fn.WebDevIconsGetFileTypeSymbol()
  end

  return nil, nil
end

return M
