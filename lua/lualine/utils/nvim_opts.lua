local M = {}

-- keeps backup of options that we cahge so we can restore it.
-- format:
-- options {
--   global = <1> {
--     name = {prev, set}
--   },
--   buffer = {
--     buf1 = <1>,
--     buf2 = <1>
--   },
--   window = {
--     win1 = <1>,
--     win2 = <1>
--   }
-- }
---@class LualineNvimOptCacheOptStore
---@field prev any
---@field set any
---@alias LualineNvimOptCacheOpt table<string, LualineNvimOptCacheOptStore>
---@class LualineNvimOptCache
---@field global LualineNvimOptCacheOptStore[]
---@field buffer table<number, LualineNvimOptCacheOptStore[]>
---@field window table<number, LualineNvimOptCacheOptStore[]>
---@type LualineNvimOptCache
local options = { global = {}, buffer = {}, window = {} }

-- helper function for M.set
local function set_opt(name, val, getter_fn, setter_fn, cache_tbl)
  -- before nvim 0.7 nvim_win_get_option... didn't return default value when
  -- the option wasn't set instead threw error.
  -- So we need pcall (probably just for test)
  local ok, cur = pcall(getter_fn, name)
  if not ok then
    cur = nil
  end
  if cur == val then
    return
  end
  if cache_tbl[name] == nil then
    cache_tbl[name] = {}
  end
  if cache_tbl[name].set ~= cur then
    if type(cur) ~= 'string' or not cur:find('lualine') then
      cache_tbl[name].prev = cur
    end
  end
  cache_tbl[name].set = val
  setter_fn(name, val)
end

-- set a option value
---@param name string
---@param val any
---@param opts table|nil when table can be {global=true | buffer = bufnr | window = winnr}
---                      when nil it's treated as {global = true}
function M.set(name, val, opts)
  if opts == nil or opts.global then
    set_opt(name, val, vim.api.nvim_get_option, vim.api.nvim_set_option, options.global)
  elseif opts.buffer then
    if options.buffer[opts.buffer] == nil then
      options.buffer[opts.buffer] = {}
    end
    set_opt(name, val, function(nm)
      return vim.api.nvim_buf_get_option(opts.buffer, nm)
    end, function(nm, vl)
      vim.api.nvim_buf_set_option(opts.buffer, nm, vl)
    end, options.buffer[opts.buffer])
  elseif opts.window then
    if options.window[opts.window] == nil then
      options.window[opts.window] = {}
    end
    set_opt(name, val, function(nm)
      return vim.api.nvim_win_get_option(opts.window, nm)
    end, function(nm, vl)
      vim.api.nvim_win_set_option(opts.window, nm, vl)
    end, options.window[opts.window])
  end
end

-- resoters old value of option name
---@param name string
---@param opts table|nil same as M.set
function M.restore(name, opts)
  if opts == nil or opts.global then
    if options.global[name] ~= nil and options.global[name].prev ~= nil then
      local restore_to = options.global[name].prev
      if type(restore_to) == 'string' and restore_to:find('lualine') then
        restore_to = ''
      end
      vim.api.nvim_set_option(name, restore_to)
    end
  elseif opts.buffer then
    if
      options.buffer[opts.buffer] ~= nil
      and options.buffer[opts.buffer][name] ~= nil
      and options.buffer[opts.buffer][name].prev ~= nil
    then
      local restore_to = options.buffer[opts.buffer][name].prev
      if type(restore_to) == 'string' and restore_to:find('lualine') then
        restore_to = ''
      end
      vim.api.nvim_buf_set_option(opts.buffer, name, restore_to)
    end
  elseif opts.window then
    if
      options.window[opts.window] ~= nil
      and options.window[opts.window][name] ~= nil
      and options.window[opts.window][name].prev ~= nil
    then
      local restore_to = options.window[opts.window][name].prev
      if type(restore_to) == 'string' and restore_to:find('lualine') then
        restore_to = ''
      end
      vim.api.nvim_win_set_option(opts.window, name, restore_to)
    end
  end
end

-- returns cache for the option name
---@param name string
---@param opts table|nil same as M.set
function M.get_cache(name, opts)
  if opts == nil or opts.global then
    if options.global[name] ~= nil and options.global[name].prev ~= nil then
      return options.global[name].prev
    end
  elseif opts.buffer then
    if
      options.buffer[opts.buffer] ~= nil
      and options.buffer[opts.buffer][name] ~= nil
      and options.buffer[opts.buffer][name].prev ~= nil
    then
      return options.buffer[opts.buffer][name].prev
    end
  elseif opts.window then
    if
      options.window[opts.window] ~= nil
      and options.window[opts.window][name] ~= nil
      and options.window[opts.window][name].prev ~= nil
    then
      return options.window[opts.window][name].prev
    end
  end
end

-- resets cache for options
function M.reset_cache()
  options = { global = {}, buffer = {}, window = {} }
end

return M
