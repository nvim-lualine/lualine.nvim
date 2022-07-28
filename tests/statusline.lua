-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

--- ## Testing module for lualines statusline
---
--- ###Uses:
---
--- Create a new instance with status width 120 & for active statusline
--- like following.
---
--- ``lua
--- local statusline = require('tests.statusline').new(120, 'active')
--- ```
---
--- To create a new instance with status width 80 & for inactive statusline use following.
---
--- ``lua
--- local statusline = require('tests.statusline').new(120, 'inactive')
--- ```
---
--- Now setup the state you want to test.
--- To test you'll call `expect` method on statusline for example.
---
--- To create a new instance with status width 80 & tabline
---
--- ``lua
--- local statusline = require('tests.statusline').new(120, 'tabline')
--- ```
---
--- Now setup the state you want to test.
--- To test you'll call `expect` method on statusline for example.
---
--- ``lua
--- statusline:expect([===[
---    highlights = {
---        1: lualine_c_inactive = { bg = "#3c3836", fg = "#a89984" }
---    }
---    |{1: [No Name] }
---    {1:                                                                                                     }
---    {1:   0:1  }|
---
---]===])
--- ```
---
--- For more flexibility you can match a patten in expect block.
--- ``lua
--- statusline:expect([===[
---    highlights = {
---        1: lualine_a_tabs_inactive = { bg = "#3c3836", bold = true, fg = "#a89984" }
---        2: lualine_transitional_lualine_a_tabs_inactive_to_lualine_a_tabs_active = { bg = "#a89984", fg = "#3c3836" }
---        3: lualine_a_tabs_active = { bg = "#a89984", bold = true, fg = "#282828" }
---        4: lualine_transitional_lualine_a_tabs_active_to_lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
---        5: lualine_c_normal = { bg = "#3c3836", fg = "#a89984" }
---    }
---    {MATCH:|{1: %d+ }}
---    {MATCH:{1: %d+ }}
---    {2:}
---    {MATCH:{3: %d+ }}
---    {4:}
---    {MATCH:{5:%s+}|}
---
---]===])
--- ```
---
--- An easy way to create an expect block is to call `snapshot` method
--- on statusline where you'll call expect and run the test. It will print
--- an expect block based on the state of statusline. You can copy it and
--- replace the snapshot call with the expect call.
---
--- ``lua
--- statusline:snapshot()
--- ```

local ffi = require('ffi')
local helpers = require('tests.helpers')
local stub = require('luassert.stub')

local M = {}

ffi.cdef([[
typedef unsigned char char_u;
typedef struct window_S win_T;
extern win_T    *curwin;
typedef struct {
  char_u      *start;
  int userhl;
} stl_hlrec_t;
typedef struct {
} StlClickDefinition;
typedef struct {
  StlClickDefinition def;
  const char *start;
} StlClickRecord;
int build_stl_str_hl(
  win_T *wp,
  char_u *out,
  size_t outlen,
  char_u *fmt,
  int use_sandbox,
  char_u fillchar,
  int maxwidth,
  stl_hlrec_t **hltab,
  StlClickRecord **tabtab
);
]])

local function process_hlrec(hltab, stlbuf, eval_type)
  local function default_hl()
    if eval_type == 'tabline' then
      return 'TabLineFill'
    elseif eval_type == 'inactive' then
      return 'StatusLineNC'
    else
      return 'StatusLine'
    end
  end
  local len = #ffi.string(stlbuf)
  local hltab_data = hltab[0]
  local result = {}
  if hltab_data[0].start ~= stlbuf then
    table.insert(result, {
      group = default_hl(),
      start = 0,
    })
  end

  local n = 0
  while hltab_data[n].start ~= nil do
    local group_name
    if hltab_data[n].userhl == 0 then
      group_name = default_hl()
    elseif hltab_data[n].userhl < 0 then
      group_name = vim.fn.synIDattr(-1 * hltab_data[n].userhl, 'name')
    else
      group_name = string.format('User%d', hltab_data[n].userhl)
    end

    local hl_pos = { group = group_name }

    if n == 0 then
      hl_pos.start = hltab_data[n].start - stlbuf
    else
      hl_pos.start = result[#result].start + result[#result].len
    end
    if hltab_data[n + 1].start ~= nil then
      hl_pos.len = hltab_data[n + 1].start - hltab_data[n].start
    else
      hl_pos.len = (stlbuf + len) - hltab_data[n].start
    end
    table.insert(result, hl_pos)
    n = n + 1
  end
  return vim.tbl_filter(function(x)
    return x.len ~= 0
  end, result)
end

local function gen_stl(stl_fmt, width, eval_type)
  local stlbuf = ffi.new('char_u [?]', width + 100)
  local fmt = ffi.cast('char_u *', stl_fmt)
  local fillchar = ffi.cast('char_u', 0x20)
  local hltab = ffi.new('stl_hlrec_t *[1]', ffi.new('stl_hlrec_t *'))
  ffi.C.build_stl_str_hl(ffi.C.curwin, stlbuf, width + 100, fmt, 0, fillchar, width, hltab, nil)
  return { str = ffi.string(stlbuf), highlights = process_hlrec(hltab, stlbuf, eval_type) }
end

local function eval_stl(stl_expr, width, eval_type)
  local stl_buf, hl_list, stl_eval_res
  if vim.fn.has('nvim-0.6') == 1 then
    stl_eval_res = vim.api.nvim_eval_statusline(
      stl_expr,
      { maxwidth = width, highlights = true, fillchar = ' ', use_tabline = (eval_type == 'tabline') }
    )
  else
    stl_eval_res = gen_stl(stl_expr, width, eval_type)
  end
  stl_buf, hl_list = stl_eval_res.str, stl_eval_res.highlights

  local hl_map = {}

  local buf = { 'highlights = {' }
  local hl_id = 1
  for _, hl in ipairs(hl_list) do
    local hl_name = hl.group
    if not hl_map[hl_name] then
      hl_map[hl_name] = require('lualine.utils.utils').extract_highlight_colors(hl_name) or {}
      table.insert(
        buf,
        string.format(' %4d: %s = %s', hl_id, hl_name, vim.inspect(hl_map[hl_name], { newline = ' ', indent = '' }))
      )
      hl_map[hl_name].id = hl_id
      hl_id = hl_id + 1
    end
  end
  table.insert(buf, '}')

  local stl = {}
  for i = 1, #hl_list do
    local start, finish = hl_list[i].start, hl_list[i + 1] and hl_list[i + 1].start or #stl_buf
    if start ~= finish then
      table.insert(
        stl,
        string.format('{%d:%s}', hl_map[hl_list[i].group].id, vim.fn.strpart(stl_buf, start, finish - start))
      )
    end
  end
  table.insert(buf, '|' .. table.concat(stl, '\n') .. '|')
  table.insert(buf, '')
  return table.concat(buf, '\n')
end

function M:expect_expr(expect, expr)
  if expr == nil then
    -- test if both are nil when running expect against nil
    assert.are.same(expect, nil)
    return
  end
  expect = helpers.dedent(expect)
  local actual = eval_stl(expr, self.width, self.type)
  local matched = true
  local errmsg = {}
  if expect ~= actual then
    expect = vim.split(expect, '\n')
    actual = vim.split(actual, '\n')
    if expect[#expect] == '' then
      expect[#expect] = nil
    end
    if actual[#actual] == '' then
      actual[#actual] = nil
    end
    for i = 1, math.max(#expect, #actual) do
      if expect[i] and actual[i] then
        local match_pat = expect[i]:match('{MATCH:(.*)}')
        if expect[i] == actual[i] or (match_pat and actual[i]:match(match_pat)) then
          expect[i] = string.rep(' ', 2) .. expect[i]
          actual[i] = string.rep(' ', 2) .. actual[i]
          goto loop_end
        end
      end
      matched = false
      if expect[i] then
        expect[i] = '*' .. string.rep(' ', 1) .. expect[i]
      end
      if actual[i] then
        actual[i] = '*' .. string.rep(' ', 1) .. actual[i]
      end
      ::loop_end::
    end
  end
  if not matched then
    table.insert(errmsg, 'Unexpected statusline')
    table.insert(errmsg, 'Expected:')
    table.insert(errmsg, table.concat(expect, '\n') .. '\n')
    table.insert(errmsg, 'Actual:')
    table.insert(errmsg, table.concat(actual, '\n'))
  end
  assert(matched, table.concat(errmsg, '\n'))
end

function M:snapshot_expr(expr)
  local type_map = {
    active = 'statusline',
    inactive = 'inactive_statusline',
    tabline = 'tabline',
  }
  print((type_map[self.type] or 'statusline') .. ':expect([===[')
  print(eval_stl(expr, self.width, self.type) .. ']===])')
end

function M:snapshot()
  local utils = require('lualine.utils.utils')
  stub(utils, 'is_focused')
  utils.is_focused.returns(self.type ~= 'inactive')
  local expr
  if self.type == 'inactive' then
    expr = require('lualine').statusline(false)
  elseif self.type == 'tabline' then
    expr = require('lualine').tabline()
  else
    expr = require('lualine').statusline(true)
  end
  self:snapshot_expr(expr)
  utils.is_focused:revert()
end

function M:expect(result)
  local utils = require('lualine.utils.utils')
  stub(utils, 'is_focused')
  utils.is_focused.returns(self.type ~= 'inactive')
  local expr
  if self.type == 'inactive' then
    expr = require('lualine').statusline(false)
  elseif self.type == 'tabline' then
    expr = require('lualine').tabline()
  else
    expr = require('lualine').statusline(true)
  end
  self:expect_expr(result, expr)
  utils.is_focused:revert()
end

function M.new(_, width, eval_type)
  if type(_) ~= 'table' then
    eval_type = width
    width = _
  end
  local self = {}
  self.width = width or 120
  self.type = eval_type
  if self.type == nil then
    self.type = 'active'
  end
  return setmetatable(self, {
    __index = M,
    __call = function(_, ...)
      M.new(...)
    end,
  })
end

return M.new()
