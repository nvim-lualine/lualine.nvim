-- Copyright (c) 2013-2021 Bailey Ling et al.
-- Copyright (c) 2023 novenary
-- MIT license, see LICENSE for more details.
-- https://github.com/vim-airline/vim-airline/blob/master/autoload/airline/extensions/whitespace.vim

local lualine_require = require('lualine_require')
local utils = require('lualine.utils.utils')
local M = lualine_require.require('lualine.component'):extend()

local default_options = {
  symbols = {
    trailing = 'trailing whitespace: ',
    long_line = 'long line: ',
    mixed_indent = 'mixed indent: ',
    mixed_indent_file = 'mixed-indent file: ',
    merge_conflict = 'merge conflict: ',
    separator = ' - ',
  },
  checks = {
    trailing = true,
    long_line = true,
    mixed_indent = true,
    mixed_indent_file = true,
    merge_conflict = true,
  },
  ft_checks = {
    make = { mixed_indent = false, mixed_indent_file = false },
    csv = { mixed_indent = false, mixed_indent_file = false },
    mail = { trailing = false },
  },
  max_lines = 20000,
  mixed_indent_mode = 0,
  timeout = 500,
  c_like_langs = {
    'arduino',
    'c',
    'cpp',
    'cuda',
    'go',
    'javascript',
    'ld',
    'php',
  },
}

local changedticks = {}
local cache = {}

local function Set(list)
  local set = {}
  for _, l in ipairs(list) do
    set[l] = true
  end
  return set
end

function M:init(options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  self.options.c_like_langs = Set(self.options.c_like_langs)
  utils.define_autocmd('CursorHold,BufWritePost', "lua require'lualine.components.whitespace'.invalidate_cache()")
end

function M:search(pat)
  return vim.fn.search(pat, 'nw', 0, self.options.timeout)
end

function M:check_trailing()
  return self:search([[\s$]])
end

function M:check_long_line()
  local tw = vim.bo.textwidth
  if tw > 0 then
    return self:search([[\%>]] .. tw .. [[v.\+]])
  end
end

function M:check_mixed_indent()
  local mode = self.options.mixed_indent_mode
  local tab_space_tab = [[(^\t* +\t\s*\S)]]
  if mode == 0 then
    -- Strict mode: any mixed indent is rejected
    return self:search([[\v(^\t+ +)|(^ +\t+)]])
  elseif mode == 1 then
    -- Reject spaces after tabs,
    -- only if there's more than the tabstop width
    local spaces_after_tabs = string.format([[(^\t+ {%d,}\S)]], vim.bo.tabstop)
    return self:search([[\v]] .. tab_space_tab .. [[|]] .. spaces_after_tabs)
  elseif mode == 2 then
    -- Allow tabs for indentation, spaces for alignment
    return self:search([[\v]] .. tab_space_tab)
  else
    error('Unknown mixed indent mode!')
  end
end

function M:check_mixed_indent_file()
  if vim.bo.expandtab then
    return self:search([[\v(^\t+)]])
  else
    if self.options.c_like_langs[vim.bo.filetype] then
      -- Allow comments of the form
      -- /*
      --  *
      --  */
      return self:search([[\v(^ +\*@!)]])
    else
      return self:search([[\v(^ +)]])
    end
  end
end

function M:check_merge_conflict()
  local annotation = [[\%([0-9A-Za-z_.:]\+\)\?]]
  local opener = [[\%(<<<<<<< ]] .. annotation .. [[\)]]
  local separator = [[\%(=======\)]]
  local closer = [[\%(>>>>>>> ]] .. annotation .. [[\)]]

  local pat = [[^\%(]] .. opener

  -- These file types use ======= as a header
  local rst = Set { 'rst', 'markdown', 'rmd' }
  if not rst[vim.bo.filetype] then
    pat = pat .. [[\|]] .. separator
  end

  pat = pat .. [[\|]] .. closer .. [[\)$]]

  return self:search(pat)
end

function M:do_checks()
  local lines = vim.fn.line('$')
  if vim.bo.readonly or not vim.bo.modifiable or lines > self.options.max_lines then
    return {}
  end

  local ft = vim.bo.filetype
  local checks = vim.tbl_extend('force', self.options.checks, self.options.ft_checks[ft] or {})

  local res = {}
  for k, v in pairs(checks) do
    if v then
      res[k] = self['check_' .. k](self)
    end
  end
  return res
end

function M:do_checks_cached()
  local bufnr = vim.api.nvim_get_current_buf()
  local cached = cache[bufnr]
  if cached then
    return cached
  end

  local res = self:do_checks()
  cache[bufnr] = res
  return res
end

function M.invalidate_cache()
  local bufnr = vim.api.nvim_get_current_buf()
  local changedtick = vim.b.changedtick
  if changedtick ~= changedticks[bufnr] then
    changedticks[bufnr] = changedtick
    cache[bufnr] = nil
  end
end

function M:update_status()
  local checks = self:do_checks_cached()

  local status = {}
  for k, v in pairs(checks) do
    if v and v ~= 0 then
      table.insert(status, string.format('%s%d', self.options.symbols[k], v))
    end
  end

  return table.concat(status, self.options.symbols.separator)
end

return M
