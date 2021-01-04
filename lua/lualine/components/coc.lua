local function coc_diagnostic_count(section)
  if vim.api.nvim_eval('exists("b:coc_diagnostic_info")') == 0 then return 0 end
  return vim.api.nvim_buf_get_var(0, 'coc_diagnostic_info')[section]
end

local function coc_diagnostic(symbol, section)
  local count = coc_diagnostic_count(section)
  if count > 0 then return symbol .. ': ' .. count else return '' end
end

local function coc_ok()
  local count = coc_diagnostic_count('error') + coc_diagnostic_count('warning')
  if count == 0 then return '✓' else return '' end
end

local function coc_status()
  if vim.fn.exists('coc_status') == 0 then return '' end
  return vim.api.nvim_get_var('coc_status')
end

local coc_errors = function() return coc_diagnostic('E', 'error') end
local coc_hints = function() return coc_diagnostic('H', 'hint') end
local coc_infos = function() return coc_diagnostic('I', 'information') end
local coc_warnings = function() return coc_diagnostic('W', 'warning') end

local function coc()
  return(
    coc_status() .. coc_errors() .. coc_warnings() ..
    coc_infos() .. coc_hints() .. coc_ok()
  )
end

return coc
