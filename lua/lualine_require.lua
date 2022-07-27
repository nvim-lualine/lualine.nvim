-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = {}

M.sep = package.config:sub(1, 1)

-- Figures out full path of lualine installation
local source = debug.getinfo(1, 'S').source
if source:sub(1, 1) == '@' then
  local base_start = source:find(table.concat({ 'lualine.nvim', 'lua', 'lualine_require.lua' }, M.sep))
  if base_start then
    source = source:sub(2, base_start + 12 + 1 + 3) -- #lualine.nvim = 12 , #lua = 3.
    if source then
      M.plugin_dir = source
    end
  end
end

--- checks if name is valied
---@param name string
---@return boolean
function M.is_valid_filename(name)
  local invalid_chars = '[^a-zA-Z0-9_. -]'
  return name:find(invalid_chars) == nil
end

---require module module
---@param module string mogule arraived
---@return any the required module
function M.require(module)
  if package.loaded[module] then
    return package.loaded[module]
  end
  local pattern_dir = module:gsub('%.', M.sep)
  local pattern_path = pattern_dir .. '.lua'
  if M.plugin_dir then
    local path = M.plugin_dir .. pattern_path
    assert(M.is_valid_filename(module), 'Invalid filename')
    local file_stat, dir_stat
    file_stat = vim.loop.fs_stat(path)
    if not file_stat then
      path = M.plugin_dir .. pattern_dir
      dir_stat = vim.loop.fs_stat(path)
      if dir_stat and dir_stat.type == 'directory' then
        path = path .. M.sep .. 'init.lua'
        file_stat = vim.loop.fs_stat(path)
      end
    end
    if file_stat and file_stat.type == 'file' then
      local mod_result = dofile(path)
      package.loaded[module] = mod_result
      return mod_result
    end
  end

  pattern_path = table.concat { 'lua/', module:gsub('%.', '/'), '.lua' }
  local paths = vim.api.nvim_get_runtime_file(pattern_path, false)
  if #paths <= 0 then
    pattern_path = table.concat { 'lua/', module:gsub('%.', '/'), '/init.lua' }
    paths = vim.api.nvim_get_runtime_file(pattern_path, false)
  end
  if #paths > 0 then
    local mod_result = dofile(paths[1])
    package.loaded[module] = mod_result
    return mod_result
  end

  return require(module)
end

---requires modules when they are used
---@param modules table k-v table where v is module path and k is name that will
---                     be indexed
---@return table metatable where when a key is indexed it gets required and cached
function M.lazy_require(modules)
  return setmetatable({}, {
    __index = function(self, key)
      local loaded = rawget(self, key)
      if loaded ~= nil then
        return loaded
      end
      local module_location = modules[key]
      if module_location == nil then
        return nil
      end
      local module = M.require(module_location)
      rawset(self, key, module)
      return module
    end,
  })
end

return M
