-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local lualine_require = require'lualine_require'
local require = lualine_require.require
local modules = lualine_require.lazy_require{
  notice = 'lualine.utils.notices',
}
local is_valid_filename = lualine_require.is_valid_filename

local sep = package.config:sub(1,1)

local component_types = {
  luaf = function(component)
    return
      require('lualine.components.special.function_component'):new(component)
  end,
  mod = function(component)
    local ok, loaded_component = pcall(require,'lualine.components.'..component[1])
    if ok then
      component.component_name = component[1]
      loaded_component = loaded_component:new(component)
      return loaded_component
    end
  end,
  stl = function(component)
    local stl_expr = component[1] -- Vim's %p %l statusline elements
    component[1] = function() return stl_expr end
    return
      require('lualine.components.special.function_component'):new(component)
  end,
  var = function(component)
    return
        require('lualine.components.special.vim_var_component'):new(component)
  end,
  ['_'] = function(component)
    return
        require('lualine.components.special.eval_func_component'):new(component)
  end
}

local function component_loader(component)
  if type(component[1]) == 'function' then
    return component_types.luaf(component)
  end
  if type(component[1]) == 'string' then
    -- load the component
    if component.type ~= nil then
      if component_types[component.type] and component.type ~= 'luaf' then
        return component_types[component.type](component)
      elseif component.type == 'vimf' or component.type == 'luae' then
        return component_types['_'](component)
      else
        modules.notice.add_notice(string.format([[
### component.type

component type '%s' isn't recognised. Check if spelling is correct.]], component.type))
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
  end
end

local function load_sections(sections, options)
  for section_name, section in pairs(sections) do
    for index, component in pairs(section) do
      if type(component) == 'string' or type(component) == 'function' then
        component = {component}
      end
      component.self = {}
      component.self.section = section_name
      -- apply default args
      component = vim.tbl_extend('keep', component, options)
      section[index] = component_loader(component)
    end
  end
end

local function load_components(config)
  load_sections(config.sections, config.options)
  load_sections(config.inactive_sections, config.options)
  load_sections(config.tabline, config.options)
end

local function load_extensions(config)
  local loaded_extensions = {}
  for _, extension in pairs(config.extensions) do
    if type(extension) == 'string' then
      local ok, local_extension = pcall(require, 'lualine.extensions.' ..extension)
      if ok then
        local_extension = vim.deepcopy(local_extension)
        load_sections(local_extension.sections, config.options)
        if local_extension.inactive_sections then
          load_sections(local_extension.inactive_sections, config.options)
        end
        if type(local_extension.init) == 'function' then
          local_extension.init()
        end
        table.insert(loaded_extensions, local_extension)
      else
        modules.notice.add_notice(string.format([[
### Extensions
Extension named `%s` was not found . Check if spelling is correct.
]], extension))
      end
    elseif type(extension) == 'table' then
      local local_extension = vim.deepcopy(extension)
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

local function load_all(config)
  load_components(config)
  load_extensions(config)
end

local function rtp_searcher(file)
  local ret = {}
  for dir in vim.gsplit(vim.api.nvim_get_option('rtp'), ',') do
    local path = dir .. sep .. file
    if vim.loop.fs_stat(path) then ret[#ret+1] = path end
  end
  return ret
end

local function load_theme(theme_name)
  assert(is_valid_filename(theme_name), "Invalid filename")
  local retval
  local path = table.concat({'lua', 'lualine', 'themes', theme_name}, sep)..'.lua'
  local files = rtp_searcher(path)
  local n_files = #files
  if n_files == 0 then
    -- No match found
    error(path .. " Not found")
  elseif n_files == 1 then
    -- when only one is found run that and return it's return value
    retval =  dofile(files[1])
  else
    -- More then 1 found . Use the first one that isn't in lualines repo
    local lualine_repo_pattern = table.concat({'lualine.nvim', 'lua', 'lualine'}, sep)
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
      retval =  dofile(files[1])
    end
  end
  return retval
end

return {
  load_all = load_all,
  load_theme = load_theme
}
