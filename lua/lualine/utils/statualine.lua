-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = {}

local gen_stl

if vim.fn.has('nvim-0.6') == 0 then
  local ffi = require('ffi')
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

  function gen_stl(stl_fmt, width)
    local stlbuf = ffi.new('char_u [?]', width + 100)
    local fmt = ffi.cast('char_u *', stl_fmt)
    local fillchar = ffi.cast('char_u', 0x20)
    local hltab = ffi.new('stl_hlrec_t *[1]', ffi.new('stl_hlrec_t *'))
    ffi.C.build_stl_str_hl(ffi.C.curwin, stlbuf, width + 100, fmt, 0, fillchar, width, hltab, nil)
    return { str = ffi.string(stlbuf)}
  end
end

function M.eval_stl(stl_expr, opts)
  local stl_eval_res
  if vim.fn.has('nvim-0.6') == 1 then
    stl_eval_res = vim.api.nvim_eval_statusline(
      stl_expr, opts)
  else
    stl_eval_res = gen_stl(stl_expr, opts.maxwidth)
  end

  return {str = stl_eval_res.str, width = stl_eval_res.width or vim.fn.strdisplaywidth(stl_eval_res.str)}
end

return M
