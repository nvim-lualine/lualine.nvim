-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function component_loader(component)
  if type(component[1]) == 'function' then
    return
        require 'lualine.components.special.function_component':new(component)
  end
  if type(component[1]) == 'string' then
    -- load the component
    local ok, loaded_component = pcall(require,
                                       'lualine.components.' .. component[1])
    if ok then
      component.component_name = component[1]
      loaded_component = loaded_component:new(component)
    elseif component[1]:find('[gvtwb]?o?:') == 1 then
      loaded_component =
          require 'lualine.components.special.vim_var_component':new(component)
    else
      loaded_component =
          require 'lualine.components.special.eval_func_component':new(component)
    end
    return loaded_component
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
  for index, extension in pairs(config.extensions) do
    if type(extension) == 'string' then
      local local_extension = vim.deepcopy(require('lualine.extensions.' .. extension))
      load_sections(local_extension.sections, config.options)
      if local_extension.inactive_sections then
        load_sections(local_extension.inactive_sections, config.options)
      end
      if type(local_extension.init) == 'function' then
        local_extension.init()
      end
      config.extensions[index] = local_extension
    elseif type(extension) == 'table' then
      local local_extension = vim.deepcopy(extension)
      load_sections(local_extension.sections, config.options)
      if local_extension.inactive_sections then
        load_sections(local_extension.inactive_sections, config.options)
      end
      if type(local_extension.init) == 'function' then
        local_extension.init()
      end
      config.extensions[index] = local_extension
    end
  end
end

local function load_all(config)
  load_components(config)
  load_extensions(config)
end

local function load(patern)
  local files = vim.fn.uniq(vim.api.nvim_get_runtime_file(patern, true))
  local n_files = #files
  if n_files == 0 then return nil
  elseif n_files == 1 then return  dofile(files[1])
  else
    for _, file in ipairs(files) do
      if not file:find('lualine.nvim') then return dofile(file) end
    end
  end
end

local function load_theme(theme_name)
  return load(table.concat(
               {'lua', 'lualine', 'themes', theme_name..'.lua'}, package.config:sub(1, 1)))
end

return {
  load_all = load_all,
  load_theme = load_theme
}
