if not jit then return false end

local file_path = debug.getinfo(1, "S").source
if file_path:sub(1,1) ~= '@' then return false end

local sep = package.config:sub(1,1)
local base_start = file_path:find(table.concat({'lualine.nvim', 'lua', 'lualine', 'utils', 'native.lua'}, sep))
if not base_start then return false end

local project_root = file_path:sub(2, base_start + 12 ) -- #lualine.nvim = 12.
local lib_path = table.concat({project_root, 'build', 'liblualine.so'}, sep)

local ffi = require'ffi'
local load_ok, lib = pcall(ffi.load, lib_path)
if not load_ok then return false end

ffi.cdef [[
  typedef struct {
    char *data;
    size_t size;
  } String;


  char *apply_transitional_separator(char *stl);
  void init();

  void free(void *ptr);
]]

local function cstr2str(str)
  local luastr = ffi.string(str)
  ffi.C.free(str)
  return luastr
end

local function str2cstr(str)
  local cstr = ffi.cast("char *", str)
  return cstr
end

local function extract_hl_color(color_group, scope)
  local name_str = ffi.new("String", {char = str2cstr(color_group), size=#color_group})
  return cstr2str(lib.extract_hl_color(ffi.cast("String *", name_str), str2cstr(scope)))
end

local function apply_transitional_separators_native(stl)
  return cstr2str(lib.apply_transitional_separator(str2cstr(stl)))
end

require'lualine.highlight'
require'lualine.utils.utils'

lib.init()
return {
  extract_hl = extract_hl_color,
  apply_ts_sep_native = apply_transitional_separators_native,
}
