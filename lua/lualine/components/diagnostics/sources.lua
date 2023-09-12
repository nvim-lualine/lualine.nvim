local M = {}

local get_nvim_diagnostic_count = function(bufnr, namespace_filter)
  local count = { 0, 0, 0, 0 }
  for key, namespace in pairs(vim.diagnostic.get_namespaces()) do
    if not vim.diagnostic.is_disabled(bufnr, key) then
      if namespace_filter == nil or namespace_filter(key, namespace) then
        for i, _ in ipairs(vim.diagnostic.severity) do
          count[i] = vim.tbl_count(vim.diagnostic.get(bufnr, { namespace = key, severity = i }))
        end
      end
    end
  end
  return count
end

---functions that how how to retrieve diagnostics from specific source.
---returns error_count:number, warning_count:number,
---        info_count:number, hint_count:number
M.sources = {
  nvim_lsp = function()
    local error_count, warning_count, info_count, hint_count
    if vim.fn.has('nvim-0.6') == 1 then
      -- On nvim 0.6+ use vim.diagnostic to get lsp generated diagnostic count.
      local namespace_filter = function(_, namespace)
        return vim.startswith(namespace.name, 'vim.lsp')
      end
      local count = get_nvim_diagnostic_count(0, namespace_filter)
      error_count = count[vim.diagnostic.severity.ERROR]
      warning_count = count[vim.diagnostic.severity.WARN]
      info_count = count[vim.diagnostic.severity.INFO]
      hint_count = count[vim.diagnostic.severity.HINT]
    else
      -- On 0.5 use older vim.lsp.diagnostic module.
      -- Maybe we should phase out support for 0.5 though I haven't yet found a solid reason to.
      -- Eventually this will be removed when 0.5 is no longer supported.
      error_count = vim.lsp.diagnostic.get_count(0, 'Error')
      warning_count = vim.lsp.diagnostic.get_count(0, 'Warning')
      info_count = vim.lsp.diagnostic.get_count(0, 'Information')
      hint_count = vim.lsp.diagnostic.get_count(0, 'Hint')
    end
    return error_count, warning_count, info_count, hint_count
  end,
  nvim_workspace_diagnostic = function()
    local count = get_nvim_diagnostic_count(nil)
    return count[vim.diagnostic.severity.ERROR],
      count[vim.diagnostic.severity.WARN],
      count[vim.diagnostic.severity.INFO],
      count[vim.diagnostic.severity.HINT]
  end,
  nvim_diagnostic = function()
    local count = get_nvim_diagnostic_count(0)
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
    local ok, data = pcall(vim.fn['ale#statusline#Count'], vim.api.nvim_get_current_buf())
    if ok then
      return data.error + data.style_error, data.warning + data.style_warning, data.info, 0
    else
      return 0, 0, 0, 0
    end
  end,
  vim_lsp = function()
    local ok, data = pcall(vim.fn['lsp#get_buffer_diagnostics_counts'])
    if ok then
      return data.error, data.warning, data.information, data.hint
    else
      return 0, 0, 0, 0
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
