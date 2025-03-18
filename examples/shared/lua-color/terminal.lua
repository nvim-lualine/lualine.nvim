---
-- ### Style terminal output
--
-- Standard colors:
-- <ul>
--  <li>black</li>
--  <li>red</li>
--  <li>green</li>
--  <li>yellow</li>
--  <li>blue</li>
--  <li>pink</li>
--  <li>cyan</li>
--  <li>white</li>
--  <li>default</li>
-- </ul>
--
-- __!__ Not all terminals support all effects  
-- __!__ Generally you can expect the colors from the list above
-- to work on all *nix systems  
-- [More information](https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_\(Select_Graphic_Rendition\)_parameters)

local Color = require "lua-color"
local utils = require "lua-color.utils"

local escape = "\x1b["

local effect_names = {
  reset = 0,
  bold = 1,
  faint = 2,
  italic = 3,
  underline = 4,
  blink = 5,
  bright = 6,
  invert = 7,
  hide = 8,
  strike = 9,
}

local color_names = {
  black = 1,
  red = 2,
  green = 3,
  yellow = 4,
  blue = 5,
  pink = 6,
  cyan = 7,
  white = 8,
  default = 10,
}

local function toSequence(...)
  return escape..table.concat({...}, ";").."m"
end

local function getColor(color)
  if type(color) == "number" then
    assert(color >= 0 and color <= 0xff)
    return 8, 5, color
  elseif type(color) == "string" then
    local c = color_names[color]
    if c then
      return c - 1
    end
  end

  return 8, 2, table.unpack(utils.map(
    {Color(color).rgb()},
    function (v) utils.round(v * 0xff) end
  ))
end


-- Export

--- Effect flags
--
-- <ul>
--  <li>reset</li>
--  <li>bold</li>
--  <li>faint</li>
--  <li>italic</li>
--  <li>underline</li>
--  <li>blink</li>
--  <li>bright</li>
--  <li>invert</li>
--  <li>hide</li>
--  <li>strike</li>
-- </ul>
local Effect = (function ()
  local r = {}
  for k, v in pairs(effect_names) do
    r[k] = 1 << v
  end
  return r
end)()

--- Set a format.
-- <br><br>
-- Options table:
-- <ul>
--  <li>`color`: Foreground color</li>
--  <li>`bg` or `background`: Background color</li>
--  <li>`font`: Number between 0 (default) and 9 to select font</li>
--  <li>An effect as `<effect_name> = true`</li>
--  <li>Flags for effects as index 1</li>
-- </ul>
--
-- @tparam table|number|string|Color options <ul>
--   <li>`number`: Effect flag</li>
--   <li>`string` or `Color`: Foreground color</li>
--   <li>`table`: Options table (above)</li>
--  </ul>
--
-- @treturn string Escape sequence
--
-- @usage -- Blue, underlined and italic
-- local tc = require "lua-color.terminal"
-- print(tc.set {
--   color = "blue",
--   tc.Effect.underline | tc.Effect.italic,
-- } .. "Hello world!" .. tc.reset())
--
-- @usage -- Red background, font number 3 and underlined
-- print(tc.set {
--   bg = Color {1, 0, 0},
--   font = 3,
--   underline = true,
-- } .. "Hello world!" .. tc.reset())
local function set(options)
  if type(options) == "number" then
    options = {options}
  elseif Color.isColor(options) or type(options) == "string" then
    options = {color = options}
  end

  local flag = options[1] or 0

  local seq = {}

  for effect, v in pairs(effect_names) do
    if options[effect] or flag & Effect[effect] ~= 0 then
      table.insert(seq, v)
    end
  end

  if options.font then
    table.insert(seq, 10 + utils.clamp(options.font, 0, 9))
  end

  if options.color then
    local c = {getColor(options.color)}
    c[1] = c[1] + 30
    if #c == 1 and (options.bright or flag & Effect.bright ~= 0) then
      c[1] = c[1] + 60
    end
    for _, v in ipairs(c) do
      table.insert(seq, v)
    end
  end
  if options.background then
    options.bg = options.background
  end
  if options.bg then
    local c = {getColor(options.bg)}
    c[1] = c[1] + 40
    if #c == 1 and (options.bright or flag & Effect.bright ~= 0) then
      c[1] = c[1] + 60
    end
    for _, v in ipairs(c) do
      table.insert(seq, v)
    end
  end

  return toSequence(table.unpack(seq))
end

--- Reset the format.
--
-- @treturn string Escape sequence
local function reset()
  return toSequence(0)
end

--- Set a format for a string.
--
-- Sets the format before the string and resets it after.
--
-- @tparam table  options Same as the options for `set`,
--  but with a `to` option for the string
--
-- @treturn string Escape sequence
--
-- @usage -- Red on green background
-- local tc = require "lua-color.terminal"
-- print(tc.apply {
--   color = "red",
--   bg = "green",
--   to = "Hello world!",
-- })
local function apply(options)
  assert(options.to, "`to` option is required!")
  return set(options)..options.to..reset()
end

--- @export
return {
  apply = apply,
  set = set,
  reset = reset,
  Effect = Effect,
}