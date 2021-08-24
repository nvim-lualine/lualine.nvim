if not jit then return nil end

local file_path = debug.getinfo(1, "S").source
if file_path:sub(1,1) ~= '@' then return nil end

local sep = package.config:sub(1,1)
local base_start = file_path:find(table.concat({'lualine.nvim', 'lua', 'lualine', 'utils', 'native.lua'}, sep))
if not base_start then return nil end

local project_root = file_path:sub(2, base_start + 12 ) -- #lualine.nvim = 12.
local lib_path = table.concat({project_root, 'build', 'liblualine.so'}, sep)

local ffi = require'ffi'
local load_ok, lib = pcall(ffi.load, lib_path)
if not load_ok then return nil end

ffi.cdef [[
  typedef struct {
    bool (*hl_exists)(char *);
    void (*create_highlight)(char *name, char *fg, char *bg);
  } Lualinelib;

  typedef struct {
    char *data;
    size_t size;
  } String;

  void init(Lualinelib *lualib);
  char *extract_hl_color(String *name, const char *scope);
  char *apply_transitional_separator(char *stl);

  void free(void *ptr);
]]

local utils = require'lualine.utils.utils'
local highlight = require'lualine.highlight'

local function cstr2str(str)
  local luastr = ffi.string(str)
  ffi.C.free(str)
  return luastr
end

local function str2cstr(str)
  local cstr = ffi.cast("char *", str)
  return cstr
end
local function Chl_exsists(hl_name)
  return ffi.cast("bool", utils.highlight_exists(ffi.string(hl_name)))
end

local function Ccreate_highlight(name, fg, bg)
  return highlight.highlight(ffi.string(name), ffi.string(fg), ffi.string(bg))
end

local function native_init()
  local lib_struct = ffi.new("Lualinelib", {
    hl_exists = ffi.cast("bool (*)(char *)", Chl_exsists),
    create_highlight = ffi.cast("void (*)(char *, char *, char *)", Ccreate_highlight)
  })
  lib.init(ffi.cast("Lualinelib *", lib_struct))
end


local function extract_hl_color(color_group, scope)
  local name_str = ffi.new("String", {char = str2cstr(color_group), size=#color_group})
  return cstr2str(lib.extract_hl_color(ffi.cast("String *", name_str), str2cstr(scope)))
end

local function apply_transitional_separators_native(stl)
  return cstr2str(lib.apply_transitional_separator(str2cstr(stl)))
end

native_init()

return {
  extract_hl = extract_hl_color,
  apply_ts_sep_native = apply_transitional_separators_native,
}
