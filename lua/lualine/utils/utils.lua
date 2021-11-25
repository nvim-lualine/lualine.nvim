-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = {}

-- Note for now only works for termguicolors scope can be bg or fg or any other
-- attr parameter like bold/italic/reverse
---@param color_group string hl_group name
---@param scope       string bg | fg
---@return table|string returns #rrggbb formated color when scope is specified
----                       or comolete color table when scope isn't specified
function M.extract_highlight_colors(color_group, scope)
  if vim.fn.hlexists(color_group) == 0 then
    return nil
  end
  local color = vim.api.nvim_get_hl_by_name(color_group, true)
  if color.background ~= nil then
    color.bg = string.format('#%06x', color.background)
    color.background = nil
  end
  if color.foreground ~= nil then
    color.fg = string.format('#%06x', color.foreground)
    color.foreground = nil
  end
  if scope then
    return color[scope]
  end
  return color
end

--- retrives color value from highlight group name in syntax_list
--- first present highlight is returned
---@param scope string
---@param syntaxlist table
---@param default string
---@return string|nil
function M.extract_color_from_hllist(scope, syntaxlist, default)
  for _, highlight_name in ipairs(syntaxlist) do
    if vim.fn.hlexists(highlight_name) ~= 0 then
      local color = M.extract_highlight_colors(highlight_name)
      if color.reverse then
        if scope == 'bg' then
          scope = 'fg'
        else
          scope = 'bg'
        end
      end
      if color[scope] then
        return color[scope]
      end
    end
  end
  return default
end

---remove empty strings from list
---@param list table
---@return table
function M.list_shrink(list)
  local new_list = {}
  for i = 1, #list do
    if list[i] and #list[i] > 0 then
      table.insert(new_list, list[i])
    end
  end
  return new_list
end

--- Check if a auto command is already defined
---@param event string
---@param patern string
---@param command_str string
---@return boolean whether autocmd is already defined
local function autocmd_is_defined(event, patern, command_str)
  return vim.api.nvim_exec(string.format('au lualine %s %s', event, patern), true):find(command_str) ~= nil
end

--- Define a auto command if it's not already defined
---@param event  string event name
---@param patern string event patern
---@param cmd    string command to run on event
function M.define_autocmd(event, patern, cmd)
  if not cmd then
    cmd = patern
    patern = '*'
  end
  if not autocmd_is_defined(event, patern, cmd) then
    vim.cmd(string.format('autocmd lualine %s %s %s', event, patern, cmd))
  end
end

-- Check if statusline is on focused window or not
function M.is_focused()
  return tonumber(vim.g.actual_curwin) == vim.fn.win_getid()
end

--- Check what's the charecter at pos
---@param str string
---@param pos number
---@return string charecter at position pos in string str
function M.charAt(str, pos)
  return string.char(str:byte(pos))
end

-- deepcopy adapted from penlight
-- https://github.com/lunarmodules/Penlight/blob/0653cdb05591454a9804a7fee8c873b8f06b0b8f/lua/pl/tablex.lua#L98-L122
local function cycle_aware_copy(t, cache)
  if type(t) ~= 'table' then
    return t
  end
  if cache[t] then
    return cache[t]
  end
  local res = {}
  cache[t] = res
  local mt = getmetatable(t)
  for k, v in pairs(t) do
    k = cycle_aware_copy(k, cache)
    v = cycle_aware_copy(v, cache)
    res[k] = v
  end
  setmetatable(res, mt)
  return res
end

--- make a deep copy of a table, recursively copying all the keys and fields.
-- This supports cycles in tables; cycles will be reproduced in the copy.
-- This will also set the copied table's metatable to that of the original.
-- @within Copying
-- @tab t A table
-- @return new table
function M.deepcopy(t)
  return cycle_aware_copy(t, {})
end

--- Check if comp is a lualine component
--- @param comp any
--- @return boolean
function M.is_component(comp)
  if type(comp) ~= 'table' then
    return false
  end
  local mt = getmetatable(comp)
  return mt and mt.__is_lualine_component == true
end

return M
