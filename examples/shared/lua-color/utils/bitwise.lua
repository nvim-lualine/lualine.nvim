-- Implementations of bitwise operators so that lua-color can be used
-- with Lua 5.1 and LuaJIT 2.1.0-beta3 (e.g. inside Neovim).

-- Code taken directly from:
-- https://stackoverflow.com/questions/5977654/how-do-i-use-the-bitwise-operator-xor-in-lua

local function bit_xor(a, b)
  local p, c = 1, 0
  while a > 0 and b > 0 do
    local ra, rb = a % 2, b % 2
    if ra ~= rb then
      c = c + p
    end
    a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
  end
  if a < b then
    a = b
  end
  while a > 0 do
    local ra = a % 2
    if ra > 0 then
      c = c + p
    end
    a, p = (a - ra) / 2, p * 2
  end
  return c
end

local function bit_or(a, b)
  local p, c = 1, 0
  while a + b > 0 do
    local ra, rb = a % 2, b % 2
    if ra + rb > 0 then
      c = c + p
    end
    a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
  end
  return c
end

local function bit_not(n)
  local p, c = 1, 0
  while n > 0 do
    local r = n % 2
    if r < 1 then
      c = c + p
    end
    n, p = (n - r) / 2, p * 2
  end
  return c
end

local function bit_and(a, b)
  local p, c = 1, 0
  while a > 0 and b > 0 do
    local ra, rb = a % 2, b % 2
    if ra + rb > 1 then
      c = c + p
    end
    a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
  end
  return c
end

local function bit_lshift(x, by)
  return x * 2 ^ by
end

local function bit_rshift(x, by)
  return math.floor(x / 2 ^ by)
end

return {
  bit_xor = bit_xor,
  bit_or = bit_or,
  bit_not = bit_not,
  bit_and = bit_and,
  bit_lshift = bit_lshift,
  bit_rshift = bit_rshift,
}
