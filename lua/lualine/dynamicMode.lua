local M = {}

M.MODES = {
  __GLOBAL__ = {}
}

function M.registerAlts(componentName, altMap)
  if altMap == nil then return end
  M.MODES[componentName] = {}
  for altName, _ in pairs(altMap) do
    M.MODES[componentName][altName] = false
    M.MODES.__GLOBAL__[altName] = false
  end
end

function M.setMode(componentName, mode)
  print('Setting mode ' .. (mode or 'nil') .. ' for component ' .. (componentName or 'nil'))
  local alts = M.MODES[componentName]
  for k, _ in pairs(M.MODES[componentName]) do
    alts[k] = false
  end

  if mode then
    M.MODES[componentName][mode] = true
  end
end

function M.setGlobal(mode, onOff)
  M.MODES.__GLOBAL__[mode] = onOff
end

function M.currentMode(componentName)
  -- if M.MODES[componentName] == nil then return end
  local componentModes = M.MODES[componentName] or {}
  for altName, isOn in pairs(componentModes) do
    if isOn or M.MODES.__GLOBAL__[altName] then return altName end
  end
end

return M
