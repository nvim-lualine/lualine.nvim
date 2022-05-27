-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

assert = require('luassert')
local eq = assert.are.same

local M = {}

M.meths = setmetatable({}, {
  __index = function(_, key)
    return vim.api['nvim_' .. key]
  end,
})

function M.init_component(component, opts)
  if component == nil then
    component = 'special.function_component'
  else
    opts.component_name = component
  end
  local comp = require('lualine.components.' .. component)
  if type(comp) == 'table' then
    comp = comp(opts)
  elseif type(comp) == 'function' then
    opts[1] = comp
    comp = require('lualine.components.special.function_component')(opts)
  end
  return comp
end

-- Checks output of a component
M.assert_component = function(component, opts, result, is_active)
  local comp = M.init_component(component, opts)
  -- for testing global options
  eq(result, comp:draw(opts.hl, is_active or true))
end

function M.assert_component_instence(comp, result)
  eq(result, comp:draw(comp.options.hl))
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
    opts.self = { section = 'c' }
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

function M.dedent(str, leave_indent)
  -- find minimum common indent across lines
  local indent = nil
  for line in str:gmatch('[^\n]+') do
    local line_indent = line:match('^%s+') or ''
    if indent == nil or #line_indent < #indent then
      indent = line_indent
    end
  end
  if indent == nil or #indent == 0 then
    -- no minimum common indent
    return str
  end
  local left_indent = (' '):rep(leave_indent or 0)
  -- create a pattern for the indent
  indent = indent:gsub('%s', '[ \t]')
  -- strip it from the first line
  str = str:gsub('^' .. indent, left_indent)
  -- strip it from the remaining lines
  str = str:gsub('[\n]' .. indent, '\n' .. left_indent)
  return str
end

return M
