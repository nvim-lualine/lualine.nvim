local FunctionComponent = require('lualine.component'):new()

FunctionComponent.update_status = function(self)
  -- 1st element in options table is the function provided by config
  return self.options[1]()
end

return FunctionComponent
