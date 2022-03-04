-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

--- ## Testing module for lualines statusline
---
--- ###Uses:
---
--- Create a new instence with status width 120 & for active statusline
--- like following.
---
--- ``lua
--- local statusline = require('tests.statusline').new(120, true)
--- ```
---
--- To create a new instence with status width 80 & for inactive statusline use following.
---
--- ``lua
--- local statusline = require('tests.statusline').new(120, true)
--- ```
---
--- Now setup the state you want to test.
--- To test you'll call `expect` pmethod on statusline for example.
---
--- ``lua
--- statusline:expect([===[
---
---]===])
--- ```
---
--- For more flexibility you can match a patten in expect block.
--- ``lua
--- statusline:expect([===[
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

local function gen_stl(stl_fmt, width)
  local stlbuf = ffi.new('char_u [?]', width + 100)
  local fmt = ffi.cast('char_u *', stl_fmt)
  local fillchar = ffi.cast('char_u', 0x20)
  local hltab = ffi.new('stl_hlrec_t *[1]', ffi.new('stl_hlrec_t *'))
  ffi.C.build_stl_str_hl(ffi.C.curwin, stlbuf, width + 100, fmt, 0, fillchar, width, hltab, nil)
  return stlbuf, hltab
end

local function process_hlrec(hltab, stlbuf)
  local len = #ffi.string(stlbuf)
  local hltab_data = hltab[0]
  local result = {}
  local n = 0
  while hltab_data[n].start ~= nil do
    local hl_pos = { name = vim.fn.synIDattr(-1 * hltab_data[n].userhl, 'name') }
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

local function eval_stl(stl_expr, width)
  local stl_buf, hltab = gen_stl(stl_expr, width)
  local hl_list = process_hlrec(hltab, stl_buf)
  stl_buf = ffi.string(stl_buf)

  local hl_map = {}

  local buf = { 'highlights = {' }
  if #hl_list == 0 then
    buf[1] = 'highlights = {}'
  else
    local hl_id = 1
    for _, hl in ipairs(hl_list) do
      local hl_name = hl.name
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
  end

  local stl = {}
  for _, hl in ipairs(hl_list) do
    table.insert(stl, string.format('{%d:%s}', hl_map[hl.name].id, vim.fn.strpart(stl_buf, hl.start, hl.len)))
  end
  table.insert(buf, '|' .. table.concat(stl, '\n') .. '|')
  table.insert(buf, '')
  return table.concat(buf, '\n')
end

function M:expect_expr(expect, expr)
  expect = helpers.dedent(expect)
  local actual = eval_stl(expr, self.width)
  local matched = true
  local errmsg = {}
  if expect ~= actual then
    expect = vim.split(expect, '\n')
    actual = vim.split(actual, '\n')
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
  print('statusline:expect [===[')
  print(eval_stl(expr, self.width) .. ']===]')
end

function M:snapshot()
  local utils = require('lualine.utils.utils')
  stub(utils, 'is_focused')
  utils.is_focused.returns(self.active)
  self:snapshot_expr(require('lualine').statusline(self.active))
  utils.is_focused:revert()
end

function M:expect(result)
  local utils = require('lualine.utils.utils')
  stub(utils, 'is_focused')
  utils.is_focused.returns(self.active)
  self:expect_expr(result, require('lualine').statusline(self.active))
  utils.is_focused:revert()
end

function M.new(_, width, active)
  if type(_) ~= 'table' then
    active = width
    width = _
  end
  local self = {}
  self.width = width or 120
  self.active = active
  if self.active == nil then
    self.active = true
  end
  return setmetatable(self, {
    __index = M,
    __call = function(_, ...)
      M.new(...)
    end,
  })
end

return M.new(120, true)
