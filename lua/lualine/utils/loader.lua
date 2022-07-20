-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local lualine_require = require('lualine_require')
local require = lualine_require.require
local modules = lualine_require.lazy_require {
  utils = 'lualine.utils.utils',
  notice = 'lualine.utils.notices',
  fn_store = 'lualine.utils.fn_store',
}
local is_valid_filename = lualine_require.is_valid_filename
local sep = lualine_require.sep

--- function that loads specific type of component
local component_types = {
  -- loads custom component
  custom = function(component)
    return component[1](component)
  end,
  --- loads lua functions as component
  lua_fun = function(component)
    return require('lualine.components.special.function_component')(component)
  end,
  --- loads lua modules as components (ones in /lua/lualine/components/)
  mod = function(component)
    local ok, loaded_component = pcall(require, 'lualine.components.' .. component[1])
    if ok then
      component.component_name = component[1]
      if type(loaded_component) == 'table' then
        loaded_component = loaded_component(component)
      elseif type(loaded_component) == 'function' then
        component[1] = loaded_component
        loaded_component = require('lualine.components.special.function_component')(component)
      end
      return loaded_component
    end
  end,
  --- loads builtin statusline patterns as component
  stl = function(component)
    local stl_expr = component[1] -- Vim's %p %l statusline elements
    component[1] = function()
      return stl_expr
    end
    return require('lualine.components.special.function_component')(component)
  end,
  --- loads variables & options (g:,go:,b:,bo:...) as components
  var = function(component)
    return require('lualine.components.special.vim_var_component')(component)
  end,
  --- loads vim functions and lua expressions as components
  ['_'] = function(component)
    return require('lualine.components.special.eval_func_component')(component)
  end,
}

---load a component from component config
---@param component table component + component options
---@return table the loaded & initialized component
local function component_loader(component)
  if type(component[1]) == 'function' then
    return component_types.lua_fun(component)
  elseif type(component[1]) == 'string' then
    -- load the component
    if component.type ~= nil then
      if component_types[component.type] and component.type ~= 'lua_fun' then
        return component_types[component.type](component)
      elseif component.type == 'vim_fun' or component.type == 'lua_expr' then
        return component_types['_'](component)
      else
        modules.notice.add_notice(string.format(
          [[
### component.type

component type '%s' isn't recognised. Check if spelling is correct.]],
          component.type
        ))
      end
    end
    local loaded_component = component_types.mod(component)
    if loaded_component then
      return loaded_component
    elseif string.char(component[1]:byte(1)) == '%' then
      return component_types.stl(component)
    elseif component[1]:find('[gvtwb]?o?:') == 1 then
      return component_types.var(component)
    else
      return component_types['_'](component)
    end
  elseif type(component[1]) == 'table' then
    return component_types.custom(component)
  end
end

--- Shows notice about invalid types passed as component
--- @param index number the index of component in section table
--- @param component table containing component elements
--- return bool whether check passed or not
local function is_valid_component_type(index, component)
  if type(component_types) == 'table' and type(index) == 'number' then
    return true
  end
  modules.notice.add_notice(string.format(
    [[
### Unrecognized component
Only functions, strings and tables can be used as component.
You seem to have a `%s` as component indexed as `%s`.
Something like:
```lua
    %s = %s,
```

This commonly occurs when you forget to pass table with option for component.
When a component has option that component needs to be a table which holds
the component as first element and the options as key value pairs.
For example:
```lua
lualine_c = {
    {'diagnostics',
        sources = {'nvim'},
    }
}
```
Notice the inner extra {} surrounding the component and it's options.
Make sure your config follows this.
]],
    type(component),
    index,
    index,
    vim.inspect(component)
  ))
  return false
end

---loads all the section from a config
---@param sections table list of sections
---@param options table global options table
local function load_sections(sections, options)
  for section_name, section in pairs(sections) do
    for index, component in pairs(section) do
      if (type(component) == 'string' or type(component) == 'function') or modules.utils.is_component(component) then
        component = { component }
      end
      if is_valid_component_type(index, component) then
        component.self = {}
        component.self.section = section_name:match('lualine_(.*)')
        -- apply default args
        component = vim.tbl_extend('keep', component, options)
        section[index] = component_loader(component)
      end
    end
  end
end

---loads all the configs (active, inactive, tabline)
---@param config table user config
local function load_components(config)
  load_sections(config.sections, config.options)
  load_sections(config.inactive_sections, config.options)
  load_sections(config.tabline, config.options)
end

---loads all the extensions
---@param config table user config
local function load_extensions(config)
  local loaded_extensions = {}
  for _, extension in pairs(config.extensions) do
    if type(extension) == 'string' then
      local ok, local_extension = pcall(require, 'lualine.extensions.' .. extension)
      if ok then
        local_extension = modules.utils.deepcopy(local_extension)
        load_sections(local_extension.sections, config.options)
        if local_extension.inactive_sections then
          load_sections(local_extension.inactive_sections, config.options)
        end
        if type(local_extension.init) == 'function' then
          local_extension.init()
        end
        table.insert(loaded_extensions, local_extension)
      else
        modules.notice.add_notice(string.format(
          [[
### Extensions
Extension named `%s` was not found . Check if spelling is correct.
]],
          extension
        ))
      end
    elseif type(extension) == 'table' then
      local local_extension = modules.utils.deepcopy(extension)
      load_sections(local_extension.sections, config.options)
      if local_extension.inactive_sections then
        load_sections(local_extension.inactive_sections, config.options)
      end
      if type(local_extension.init) == 'function' then
        local_extension.init()
      end
      table.insert(loaded_extensions, local_extension)
    end
  end
  config.extensions = loaded_extensions
end

---loads sections and extensions or entire user config
---@param config table user config
local function load_all(config)
  require('lualine.component')._reset_components()
  modules.fn_store.clear_fns()
  load_components(config)
  load_extensions(config)
end

---loads a theme from lua module
---prioritizes external themes (from user config or other plugins) over the bundled ones
---@param theme_name string
---@return table theme definition from module
local function load_theme(theme_name)
  assert(is_valid_filename(theme_name), 'Invalid filename')
  local retval
  local path = table.concat { 'lua/lualine/themes/', theme_name, '.lua' }
  local files = vim.api.nvim_get_runtime_file(path, true)
  if #files <= 0 then
    path = table.concat { 'lua/lualine/themes/', theme_name, '/init.lua' }
    files = vim.api.nvim_get_runtime_file(path, true)
  end
  local n_files = #files
  if n_files == 0 then
    -- No match found
    error(path .. ' Not found')
  elseif n_files == 1 then
    -- when only one is found run that and return it's return value
    retval = dofile(files[1])
  else
    -- More then 1 found . Use the first one that isn't in lualines repo
    local lualine_repo_pattern = table.concat({ 'lualine.nvim', 'lua', 'lualine' }, sep)
    local file_found = false
    for _, file in ipairs(files) do
      if not file:find(lualine_repo_pattern) then
        retval = dofile(file)
        file_found = true
        break
      end
    end
    if not file_found then
      -- This shouldn't happen but somehow we have multiple files but they
      -- apear to be in lualines repo . Just run the first one
      retval = dofile(files[1])
    end
  end
  return retval
end

return {
  load_all = load_all,
  load_theme = load_theme,
}
