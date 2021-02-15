-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local function diagnostics(options)
  return function()
    local error_count, warning_count, info_count = 0,0,0
    if options.sources~=nil then
      for _, source in ipairs(options.sources) do
        if source == 'lsp' then
          error_count = error_count +  vim.lsp.diagnostic.get_count(0, 'Error')
          warning_count = warning_count +  vim.lsp.diagnostic.get_count(0, 'Warning')
          -- info_count = info_count +  vim.lsp.diagnostic.get_count(0, 'Info')
        end
      end
    end print(error_count)
    local result = {}
    local symbols = {
      'E',
      'W',
      'I'
    }
    local data = {
      error_count,
      warning_count,
      info_count
    }
    for range=1,3 do
      if data[range] ~= nil and data[range] > 0 then
      table.insert(result,symbols[range]..':'..data[range]..' ')
      end
    end
    print(result[1])
    if result[1] ~= nil then
      return table.concat(result, '')
    else
      return ''
    end
  end
end

return { init = function(options) return diagnostics(options) end }
