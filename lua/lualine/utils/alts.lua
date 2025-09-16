local dynamicMode = require('lualine.dynamicMode')
local loader = require('lualine.utils.loader')

local M = {}

--- Create a component-options table based off of the source options,
--- and adding any additional options for the alt state
--- (which will either supplement or override the source options)
---@param altName string
---@param componentOpts table
---@param additionalAltOpts table
function M.inheritAltOptions(altName, componentOpts, additionalAltOpts)
  local altOpts = {}
  for _, src in pairs({componentOpts, additionalAltOpts}) do
    for k, v in pairs(src) do
      if k ~= 'alts' then
        altOpts[k] = v
      end
    end
  end

  altOpts.__isAlt = true
  altOpts['component_name'] = componentOpts['component_name'] .. '_mode_' .. altName
  return altOpts
end

---@param altName string
function M.effectiveAltname(altName)
  local effectiveName
  local isNegation = false

  if altName:sub(1, 1)  == '!' then
    isNegation = true
    effectiveName = altName:sub(2)
  end
  effectiveName = altName

  return effectiveName, isNegation
end

function M.initAlts(componentOpts)
  local altMap = componentOpts.alts or {}

  local altNames = {}
  for altName, _ in pairs(altMap or {}) do
    altNames[#altNames+1] = altName
  end
  dynamicMode.registerAlts(componentOpts.component_name, altNames)

  local alts = {}
  for altName, extraOptions in pairs(altMap) do
    local altOpts = M.inheritAltOptions(altName, componentOpts, extraOptions)
    local altComponent = loader.component_loader(altOpts)
    alts[altName] = altComponent
  end

  return alts
  
end

function M.altModeCondition(componentName, altModes, existingCond, fallback)
  existingCond = existingCond or function() return true end
  local effectiveAltModes = {}
  for _, mode in pairs(altModes) do
    effectiveName, isNegation = M.effectiveAltname(mode)
    effectiveAltModes[#effectiveAltModes+1] = mode
  end


  dynamicMode.registerAlts(
    componentName,
    effectiveAltModes
  )
  local cond = function()
    if not existingCond() then return false end

    local currentMode = dynamicMode.getMode(componentName)
    if componentName == 'diagnosticsFilter' then
      print('Mode for component ' .. componentName .. ': ' .. (currentMode or 'nil'))
    end
    if currentMode == nil and fallback then
      print('Falling back for component ' .. componentName)
      return true
    end

    -- If any altMode is the current mode, display the component.
    -- Negations (prefixed with "!") act as an AND gate, 
    -- and assertions act as an OR gate
    -- (any positive match is sufficient, but all negative matches are required)

    -- if there are assertions, at least one must be true 
    local hasAssertion = false
    for _, mode in pairs(altModes) do
      local effectiveName, isNegation = M.effectiveAltname(mode)
      hasAssertion = hasAssertion or not isNegation
    end

    -- if there are any assertions, so we will start off with a false condition 
    -- otherwise, we default to true and assume only negation conditions 
    local passesAssertions = not hasAssertion
    local passesNegations = true
    for _, mode in pairs(altModes) do
      local effectiveName, isNegation = M.effectiveAltname(mode)
      if isNegation then
        passesNegations = passesNegations and mode ~= currentMode
      else
        passesAssertions = passesAssertions or mode == currentMode
      end
    end
    return passesNegations and passesAssertions
  end

  return cond
end

return M
