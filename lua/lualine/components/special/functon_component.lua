local FunctionComponent = require('lualine.component'):new()

FunctionComponent.new = function(self, options, child)
  local new_instence = self._parent:new(options, child or FunctionComponent)
  new_instence.update_status = options[1]
  return new_instence
end

return FunctionComponent
