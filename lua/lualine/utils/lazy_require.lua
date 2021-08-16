return function(modules)
  return setmetatable({}, {
    __index = function(self, key)
      local loaded = rawget(self, key)
      if loaded ~= nil then return loaded end
      local module_location = modules[key]
      if module_location == nil then return nil end
      local module = require(module_location)
      rawset(self, key, module)
      return module
    end
  })
end
