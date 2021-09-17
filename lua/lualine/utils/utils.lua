-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = {}

-- Note for now only works for termguicolors scope can be bg or fg or any other
-- attr parameter like bold/italic/reverse
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

-- retrives color value from highlight group name in syntax_list
-- first present highlight is returned
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

-- remove empty strings from list
function M.list_shrink(list)
  local new_list = {}
  for i = 1, #list do
    if list[i] and #list[i] > 0 then
      table.insert(new_list, list[i])
    end
  end
  return new_list
end

-- Check if a auto command is already defined
local function autocmd_is_defined(event, patern, command_str)
  return vim.api.nvim_exec(string.format('au lualine %s %s', event, patern), true):find(command_str) ~= nil
end

-- Define a auto command if it's not already defined
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

function M.charAt(str, pos)
  return string.char(str:byte(pos))
end

return M
