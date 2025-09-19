local M = {}

-- TODO refactor - no need to map mode->isOn for component-modes
-- we only need capabilities for multiple *global* modes to be turned on at once - local modes only need to be turned on 


M.MODES = {
  __GLOBAL__ = 'normal'
}

M.REGISTERED_MODES = {}

function M.registerAlts(componentName, altModes)
  M.MODES[componentName] = nil
  for _, mode in pairs(altModes) do
    M.REGISTERED_MODES[mode] = true
  end
end

function M.registeredModes()
  local modes = {}
  for mode, _ in pairs(M.REGISTERED_MODES) do
    modes[#modes+1] = mode
  end
  return modes
end


function M.setMode(componentName, mode)
  M.MODES[componentName] = mode
end

function M.setGlobalMode(mode)
  M.MODES.__GLOBAL__ = mode
end

function M.nukeAll()
  for comp, _ in pairs(M.MODES) do
    if comp ~= '__GLOBAL__' then M.setMode(comp, nil) end
  end
end

function M.getMode(componentName)
  return M.MODES[componentName] or M.MODES.__GLOBAL__
end

return M
