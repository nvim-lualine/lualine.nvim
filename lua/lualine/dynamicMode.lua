local M = {}

M.MODES = {
  __GLOBAL__ = {
    normal = true
  }
}

function M.registerAlts(componentName, alts)
  M.MODES[componentName] = {}
  for _, altName in ipairs(alts) do
    M.MODES[componentName][altName] = false
    M.setGlobalMode(altName, false)
    -- M.MODES.__GLOBAL__[altName] = false
  end
  -- print('Registered alts for component ' .. componentName .. ': ' .. vim.inspect(M.MODES[componentName]))
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
  -- do not allow the "normal" mode to be explicitly edited
  -- (when a mode is registered, it's set to false by default,
  -- but we *do* want to register the "normal" mode sometimes,
  -- so that a component can require that mode=normal as a display condition)
  if mode == 'normal' then return end
  M.MODES.__GLOBAL__[mode] = onOff
  print('Setting global mode ' .. mode .. ' to ' .. (onOff and 'true' or 'false'))
  local allOff = true
  for mode, isOn in pairs(M.MODES.__GLOBAL__) do
    if mode ~= 'normal' then
      allOff = allOff and not isOn
    end
  end

  M.MODES.__GLOBAL__.normal = allOff
end

function M.nukeGlobal()
  for mode, _ in pairs(M.MODES.__GLOBAL__) do
    M.MODES.__GLOBAL__[mode] = false
  end
end

function M.nukeAll()
for comp, _ in pairs(M.MODES) do
  if comp ~= '__GLOBAL__' then M.setMode(comp, nil) end
  end
end

function M.getMode(componentName)
  -- if M.MODES[componentName] == nil then return end
  local componentModes = M.MODES[componentName] or {}
  for altName, isOn in pairs(componentModes) do
    if isOn then return altName end
  end
  for altName, _ in pairs(componentModes) do
    local isOn = M.MODES.__GLOBAL__[altName]
    if isOn then return altName end
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
