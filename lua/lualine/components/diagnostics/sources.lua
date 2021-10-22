local M = {}

---functions that how how to retrieve diagnostics from specific source.
---returns error_count:number, warning_count:number,
---        info_count:number, hint_count:number
M.sources = {
  nvim_lsp = function()
    local error_count = vim.lsp.diagnostic.get_count(0, 'Error')
    local warning_count = vim.lsp.diagnostic.get_count(0, 'Warning')
    local info_count = vim.lsp.diagnostic.get_count(0, 'Information')
    local hint_count = vim.lsp.diagnostic.get_count(0, 'Hint')
    return error_count, warning_count, info_count, hint_count
  end,
  nvim = function()
    local diagnostics = vim.diagnostic.get(0)
    local count = { 0, 0, 0, 0 }
    for _, diagnostic in ipairs(diagnostics) do
      count[diagnostic.severity] = count[diagnostic.severity] + 1
    end
    return count[vim.diagnostic.severity.ERROR],
      count[vim.diagnostic.severity.WARN],
      count[vim.diagnostic.severity.INFO],
      count[vim.diagnostic.severity.HINT]
  end,
  coc = function()
    local data = vim.b.coc_diagnostic_info
    if data then
      return data.error, data.warning, data.information, data.hint
    else
      return 0, 0, 0, 0
    end
  end,
  ale = function()
    local ok, data = pcall(vim.fn['ale#statusline#Count'], vim.fn.bufnr())
    if ok then
      return data.error + data.style_error, data.warning + data.style_warning, data.info, 0
    else
      return 0, 0, 0, 0
    end
  end,
  vim_lsp = function()
    local ok, data = pcall(vim.fn['lsp#get_buffer_diagnostics_counts'])
    if ok then
      return data.error, data.warning, data.information
    else
      return 0, 0, 0
    end
  end,
}

---returns list of diagnostics count from all sources
---@param sources table list of sources
---@return table {{error_count, warning_count, info_count, hint_count}}
M.get_diagnostics = function(sources)
  local result = {}
  for index, source in ipairs(sources) do
    if type(source) == 'string' then
      local error_count, warning_count, info_count, hint_count = M.sources[source]()
      result[index] = {
        error = error_count,
        warn = warning_count,
        info = info_count,
        hint = hint_count,
      }
    elseif type(source) == 'function' then
      local source_result = source()
      source_result = type(source_result) == 'table' and source_result or {}
      result[index] = {
        error = source_result.error or 0,
        warn = source_result.warn or 0,
        info = source_result.info or 0,
        hint = source_result.hint or 0,
      }
    end
  end
  return result
end

return M
