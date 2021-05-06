-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local function component_loader(component)
  if type(component[1]) == 'function' then
    return require 'lualine.components.special.function_component':new(component)
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
  local async_loader
  async_loader = vim.loop.new_async(vim.schedule_wrap(
                                        function()
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
        async_loader:close()
      end))
  async_loader:send()
end

local function load_components(config)
  load_sections(config.sections, config.options)
  load_sections(config.inactive_sections, config.options)
  load_sections(config.tabline, config.options)
end

local function load_extensions(config)
  for index, extension in pairs(config.extensions) do
    local local_extension = require('lualine.extensions.' .. extension)
    load_sections(local_extension.sections, config.options)
    load_sections(local_extension.inactive_sections, config.options)
    config.extensions[index] = local_extension
  end
end

return {load_components = load_components, load_extensions = load_extensions}
