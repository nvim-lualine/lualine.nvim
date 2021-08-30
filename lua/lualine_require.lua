local M = {}

M.sep = package.config:sub(1,1)

local source = debug.getinfo(1, "S").source
if source:sub(1,1) == '@' then
  local base_start = source:find(table.concat({'lualine.nvim', 'lua', 'lualine_require.lua'}, M.sep))
  if base_start then
    source = source:sub(2, base_start + 12 + 1 + 3) -- #lualine.nvim = 12 , #lua = 3.
    if source then M.plugin_dir = source end
  end
end

function M.is_valid_filename(name)
  local invalid_chars="[^a-zA-Z0-9_. -]"
  return name:find(invalid_chars) == nil
end

function M.require(module)
  if package.loaded[module] then return package.loaded[module] end
  if M.plugin_dir then
    local path = M.plugin_dir .. module:gsub('%.', M.sep) .. '.lua'
    assert(M.is_valid_filename(module), "Invalid filename")
    if vim.loop.fs_stat(path) then
      local mod_result = dofile(path)
      package.loaded[module] = mod_result
      return mod_result
    end
  end
  return require(module)
end

function M.lazy_require(modules)
  return setmetatable({}, {
    __index = function(self, key)
      local loaded = rawget(self, key)
      if loaded ~= nil then return loaded end
      local module_location = modules[key]
      if module_location == nil then return nil end
      local module = M.require(module_location)
      rawset(self, key, module)
      return module
    end
  })
end

return M
