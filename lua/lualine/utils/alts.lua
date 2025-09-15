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

function M.altModeCondition(componentName, altModes, existingCond)
  existingCond = existingCond or function() return true end

  dynamicMode.registerAlts(
    componentName,
    altModes
  )
  local cond = function()
    if not existingCond() then return false end

    local currentMode = dynamicMode.getMode(componentName)

    -- If any altMode is the current mode, display the component.
    -- Negations (prefixed with "!") act as an AND gate, 
    -- and assertions act as an OR gate
    -- (any positive match is sufficient, but all negative matches are required)
    local passesNegations = true
    local passesAssertions = nil
    for _, mode in pairs(altModes) do
      local effectiveName, isNegation = M.effectiveAltname(mode)
      if isNegation then
        print('Negation for name ' .. effectiveName)
        passesNegations = passesNegations and mode ~= currentMode
      else
        print('Non-Negation for name ' .. effectiveName)
        passesAssertions = passesAssertions or mode == currentMode
      end
    end
    return passesNegations and passesAssertions ~= false
  end

  return cond
end

return M
