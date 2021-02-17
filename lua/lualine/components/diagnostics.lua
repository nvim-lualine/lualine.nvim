-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local highlight = require('lualine.highlight')
local utils = require('lualine.utils.utils')

local diagnostic_sources = {
	nvim_lsp = function()
    local error_count = vim.lsp.diagnostic.get_count(0, 'Error')
    local warning_count = vim.lsp.diagnostic.get_count(0, 'Warning')
    local info_count = vim.lsp.diagnostic.get_count(0, 'Information')
		return error_count, warning_count, info_count
	end,
	coc = function()
		if not vim.b.coc_diagnostic_info then return -1, -1, -1 end
		local error_count = vim.b.coc_diagnostic_info.error
		local warning_count = vim.b.coc_diagnostic_info.warning
		local info_count = vim.b.coc_diagnostic_info.information
		return error_count, warning_count, info_count
	end,
	ale = function()
		if vim.fn.exists('*ale#statusline#Count') == 1 then
			local data = vim.fn['ale#statusline#Count'](vim.fn.bufnr())
			return data.error, data.warning, data.info
		end
		return -1, -1, -1
	end,
}

local function diagnostics(options)
	local symbols
	if options.icons_enabled then
		symbols = {
			'', -- xf659
			'', -- xf529
			'', -- xf7fc
		}
	else
		symbols = { 'E', 'W', 'I' }
	end
	if options.colored == nil then options.colored = true end

	local default_color_error = { fg = '#e32636' }
	local default_color_warn  = { fg = '#ffdf00' }
	local default_color_info  = { fg = '#ffffff' }

	if options.color_error == nil then options.color_error = default_color_error end
	if options.color_warn == nil then options.color_warn = default_color_warn end
	if options.color_info == nil then options.color_info = default_color_info end

	local highlight_groups = {}
	local function add_highlights()
		highlight_groups = {
			highlight.create_component_highlight_group(options.color_error, 'diagnostics_error', options),
			highlight.create_component_highlight_group(options.color_warn, 'diagnostics_warn', options),
			highlight.create_component_highlight_group(options.color_info, 'diagnostics_info', options),
		}
	end

	if options.colored then
		add_highlights()
		utils.expand_set_theme(add_highlights)
		options.custom_highlight = true
	end

  return function()
    local error_count, warning_count, info_count = 0,0,0
    if options.sources~=nil then
      for _, source in ipairs(options.sources) do
				local E, W, I = diagnostic_sources[source]()
				error_count   = error_count   + E
				warning_count = warning_count + W
				info_count    = info_count    + I
      end
    end
    local result = {}
    local data = {
      error_count,
      warning_count,
      info_count
    }
		local colors = {}
		if options.colored then
			for _, hl in pairs(highlight_groups) do
				table.insert(colors, highlight.component_format_highlight(hl))
			end
		end
		local separator = ':'
		if options.icons_enabled then separator = ' ' end
    for range=1,3 do
      if data[range] ~= nil and data[range] > 0 then
				if options.colored then
					table.insert(result,table.concat{colors[range], symbols[range], separator, data[range]})
				else
					table.insert(result,symbols[range]..separator..data[range])
				end
      end
    end
    if result[1] ~= nil then
      return table.concat(result, ' ')
    else
      return ''
    end
  end
end

return { init = function(options) return diagnostics(options) end }
