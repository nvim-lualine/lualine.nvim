local eq = assert.are.same

local M = {}

M.meths = setmetatable({}, {
  __index = function(_, key)
    return vim.api['nvim_' .. key]
  end,
})

-- Checks ouput of a component
M.assert_component = function(component, opts, result)
  -- for testing global options
  if component == nil then
    component = 'special.function_component'
  end
  local comp = require('lualine.components.' .. component):new(opts)
  eq(result, comp:draw(opts.hl))
end

-- sets defaults for component options
M.build_component_opts = function(opts)
  if not opts then
    opts = {}
  end
  if opts[1] == nil then
    opts[1] = function()
      return 'test'
    end
  end
  if not opts.self then
    opts.self = { section = 'lualine_c' }
  end
  if not opts.theme then
    opts.theme = 'gruvbox'
  end
  if not opts.hl then
    opts.hl = ''
  end
  if opts.icons_enabled == nil then
    opts.icons_enabled = true
  end
  if not opts.component_separators then
    opts.component_separators = { left = '', right = '' }
  end
  if not opts.section_separators then
    opts.section_separators = { left = '', right = '' }
  end
  return opts
end

M.P = function(t)
  print(vim.inspect(t))
end

return M
