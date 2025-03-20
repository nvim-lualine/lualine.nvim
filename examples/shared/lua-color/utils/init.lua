local function min_index(first, ...)
  local min, index = first, 1
  for i, v in ipairs {...} do
    if v < min then
      min, index = v, i + 1
    end
  end
  return min, index
end

local function max_index(first, ...)
  local max, index = first, 1
  for i, v in ipairs {...} do
    if v > max then
      max, index = v, i + 1
    end
  end
  return max, index
end

local function round(x)
  return x + 0.5 - (x + 0.5) % 1
end

local function clamp(x, min, max)
  return x < min and min or x > max and max or x
end

local function map(t, cb)
  local n = {}
  for i, v in ipairs(t) do
    n[i] = cb(v)
  end
  return n
end

return {
  min = min_index,
  max = max_index,
  round = round,
  clamp = clamp,
  map = map,
}
