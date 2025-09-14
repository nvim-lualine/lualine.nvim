local M = {}

M.MODES = {
  __GLOBAL__ = {}
}

function M.registerAlts(componentName, alts)
  M.MODES[componentName] = {}
  for _, altName in ipairs(alts) do
    M.MODES[componentName][altName] = false
    M.MODES.__GLOBAL__[altName] = false
  end
end

function M.setMode(componentName, mode)
  local alts = M.MODES[componentName]
  for k, _ in pairs(M.MODES[componentName]) do
    alts[k] = false
  end

  if mode then
    M.MODES[componentName][mode] = true
  end
end

function M.setGlobalMode(mode, onOff)
  M.MODES.__GLOBAL__[mode] = onOff
end

function M.getMode(componentName)
  -- if M.MODES[componentName] == nil then return end
  local componentModes = M.MODES[componentName] or {}
  for altName, isOn in pairs(componentModes) do
    if isOn or M.MODES.__GLOBAL__[altName] then return altName end
  end
end

function M.registeredModes()
  local modes = {}
  for altName, _ in pairs(M.MODES.__GLOBAL__) do
    modes[#modes+1] = altName
  end
  return modes
end

return M
