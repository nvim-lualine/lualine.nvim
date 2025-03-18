--- Parse, convert and manipulate color values.
--
-- @classmod Color



local utils = require "shared.lua-color.utils"
local class = require "shared.lua-color.utils.class"


-- Lua 5.1 compat
local bitwise = require "shared.lua-color.utils.bitwise"
local bit_and = bitwise.bit_and
local bit_lshift = bitwise.bit_lshift
local bit_rshift = bitwise.bit_rshift


-- Utils


local function hcm_to_rgb(h, c, m)
	local r, g, b = 0, 0, 0

	h = h * 6
	local x = c * (1 - math.abs(h % 2 - 1))

	if h <= 1 then
		r, g, b = c, x, 0
	elseif h <= 2 then
		r, g, b = x, c, 0
	elseif h <= 3 then
		r, g, b = 0, c, x
	elseif h <= 4 then
		r, g, b = 0, x, c
	elseif h <= 5 then
		r, g, b = x, 0, c
	elseif h <= 6 then
		r, g, b = c, 0, x
	end

	return r + m, g + m, b + m
end

local function tonumPercent(str)
	if str:sub(-1) == "%" then
		return tonumber(str:sub(1, #str - 1)) / 100
	end
	return tonumber(str)
end



-- Color


--- Color constructor.
--
-- @function Color:__call
--
-- @tparam ?string|table|Color value Color value (default: `nil`)
--
-- @see Color:set

--- Red component.
-- @field r

--- Green component.
-- @field g

--- Blue component.
-- @field b

--- Alpha component.
-- @field a


--- Color class
local Color = class(nil, function(this, value)
	if value then
		this:set(value)
	end
end, {
	__is_color = true,
	r = 0,
	g = 0,
	b = 0,
	a = 1,
})

--- Table of color names.
-- <br>
-- Can be set to a table containing named colors to be used by `Color:set`
-- <br>
-- Values must be compatible with `Color:set`
-- <br>
-- Default: `nil`
--
-- @usage  Color.colorNames = { red = "#ff0000", green = "#00ff00", blue = "#0000ff" }
--local color = Color "green"
Color.colorNames = nil

--- Clone color
--
-- @treturn Color copy
function Color:clone()
	return Color(self)
end

--- Set color to value.
-- <br>
-- Called by constructor
-- <br><br>
-- Possible value types:
-- <ul>
--  <li>`Color`</li>
--  <li>color name as specified in `Color.colorNames`</li>
--  <li>css style functions as string:<ul>
--   <li>`rgb(r, g, b)`</li>
--   <li>`rgba(r, g, b, a)`</li>
--   <li>`hsl(h, s, l)`</li>
--   <li>`hsla(h, s, l, a)`</li>
--   <li>`hsv(h, s, v)`</li>
--   <li>`hsva(h, s, v, a)`</li>
--   <li>`hwb(h, w, b)`</li>
--   <li>`hwba(h, w, b, a)`</li>
--   <li>`cmyk(c, m, y, k)`</li>
--   </ul>
--   Values are in the same ranges as in css ([0;255] for rgb, [0;1] for alpha, ...)<br>
--   functions can be specified in a simplified syntax: `rgb(r, g, b) == rgb r g b`
--  </li>
--  <li>NCol string: `R10, 50%, 50%`</li>
--  <li>hex string: `#rgb` | `#rgba` | `#rrggbb` | `#rrggbbaa` (`#` can be omitted)</li>
--  <li>rgb values in [0;1]: `{r, g, b[, a]}` | `{r=r, g=g, b=b[, a=a]}`</li>
--  <li>hsv values in [0;1]: `{h=h, s=s, v=v[, a=a]}`</li>
--  <li>hsl values in [0;1]: `{h=h, s=s, l=l[, a=a]}`</li>
--  <li>hwb values in [0;1]: `{h=h, w=w, b=b[, a=a]}`</li>
--  <li>cmyk values in [0;1]: `{c=c, m=m, y=y, k=k}`</li>
--  <li>single set mode, table with any combination of the following: <ul>
--   <li>`red`</li>
--   <li>`green`</li>
--   <li>`blue`</li>
--   <li>`alpha`</li>
--   <li>`hue`</li>
--   <li>`saturation`</li>
--   <li>`value`</li>
--   <li>`lightness`</li>
--   <li>`whiteness`</li>
--   <li>`blackness`</li>
--   <li>`cyan`</li>
--   <li>`magenta`</li>
--   <li>`yellow`</li>
--   <li>`key`</li>
--   </ul>
--   All values are in `[0;1]`.<br>
--   They will be applied in the order: `rgba -> hsl -> hwb -> hsv -> cmyk`<br>
--   If `lightness` is given, saturation is treated as hsl saturation,
--   otherwise it will be treated as hsv saturation.
--  </li>
-- </ul>
--
-- @see Color:__call
--
-- @tparam string|table|Color value Color
--
-- @treturn Color self
--
-- @usage color:set "#f1f1f1"
-- @usage color:set "rgba(241, 241, 241, 0.5)"
-- @usage color:set "hsl 180 100% 20%"
-- @usage color:set { r = 0.255, g = 0.729, b = 0.412 }
-- @usage color:set { 0.255, 0.729, 0.412 } -- same as above
-- @usage color:set { h = 0.389, s = 0.65, v = 0.73 }
function Color:set(value)
	assert(value)

	-- from Color
	if value.__is_color then
		self.r = value.r
		self.g = value.g
		self.b = value.b
		self.a = value.a
	elseif type(value) == "string" then
		self.a = 1

		if value:sub(1, 1) ~= "#" then
			if Color.colorNames then
				local c = Color.colorNames[value]
				if c then return self:set(c) end
			end

			local func, values = value:match "(%w+)[ %(]+([x ,.%x%%]+)"
			if func ~= nil then
				if func == "rgb" then
					local r, g, b = values:match "([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)"
					assert(r and g and b)
					self.r = tonumber(r) / 0xff
					self.g = tonumber(g) / 0xff
					self.b = tonumber(b) / 0xff
					return self
				elseif func == "rgba" then
					local r, g, b, a = values:match "([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+%%?)"
					assert(r and g and b and a)
					self.r = tonumber(r) / 0xff
					self.g = tonumber(g) / 0xff
					self.b = tonumber(b) / 0xff
					self.a = tonumPercent(a)
					return self
				elseif func == "hsv" then
					local h, s, v = values:match "([x.%x]+)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
					assert(h and s and v)
					return self:set {
						h = tonumber(h) / 360,
						s = tonumPercent(s),
						v = tonumPercent(v),
					}
				elseif func == "hsva" then
					local h, s, v, a = values:match "([x.%x]+)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
					assert(h and s and v and a)
					return self:set {
						h = tonumber(h) / 360,
						s = tonumPercent(s),
						v = tonumPercent(v),
						a = tonumPercent(a)
					}
				elseif func == "hsl" then
					local h, s, l = values:match "([x.%x]+)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
					assert(h and s and l)
					return self:set {
						h = tonumber(h) / 360,
						s = tonumPercent(s),
						l = tonumPercent(l),
					}
				elseif func == "hsla" then
					local h, s, l, a = values:match "([x.%x]+)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
					assert(h and s and l and a)
					return self:set {
						h = tonumber(h) / 360,
						s = tonumPercent(s),
						l = tonumPercent(l),
						a = tonumPercent(a)
					}
				elseif func == "hwb" then
					local h, w, b = values:match "([x.%x]+)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
					assert(h and w and b)
					return self:set {
						h = tonumber(h) / 360,
						w = tonumPercent(w),
						b = tonumPercent(b),
					}
				elseif func == "hwba" then
					local h, w, b, a = values:match "([x.%x]+)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
					assert(h and w and b and a)
					return self:set {
						h = tonumber(h) / 360,
						w = tonumPercent(w),
						b = tonumPercent(b),
						a = tonumPercent(a)
					}
				elseif func == "cmyk" then
					local c, m, y, k = values:match "([x.%x]+%%?)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
					assert(c and m and y and k)
					return self:set {
						c = tonumPercent(c),
						m = tonumPercent(m),
						y = tonumPercent(y),
						k = tonumPercent(k),
					}
				end
			else
				local col, dist, w, b, a = value:match "([RGBCMYrgbcmy])(%d*)[, ]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
				if col == nil then
					col, dist, w, b, a = value:match "([RGBCMYrgbcmy])(%d*)[, ]+([x.%x]+%%?)[ ,]+([x.%x]+%%?)"
				end
				if col then
					col = col:lower()

					local h
					if col == "r" then
						h = 0
					elseif col == "y" then
						h = 1 / 6
					elseif col == "g" then
						h = 2 / 6
					elseif col == "c" then
						h = 3 / 6
					elseif col == "b" then
						h = 4 / 6
					elseif col == "m" then
						h = 5 / 6
					end

					if #dist > 0 then h = h + tonumber(dist) / 600 end

					return self:set {
						h = h,
						w = tonumPercent(w),
						b = tonumPercent(b),
						a = a and tonumPercent(a) or 1
					}
				end
			end
		else
			value = value:sub(2)
		end

		local pattern
		local div = 0xff
		if #value == 3 then
			pattern = "(%x)(%x)(%x)"
			div = 0xf
		elseif #value == 4 then
			pattern = "(%x)(%x)(%x)(%x)"
			div = 0xf
		elseif #value == 6 then
			pattern = "(%x%x)(%x%x)(%x%x)"
		elseif #value == 8 then
			pattern = "(%x%x)(%x%x)(%x%x)(%x%x)"
		else
			error "Not a valid color"
		end
		local r, g, b, a = value:match(pattern)
		assert(r ~= nil, "Not a valid color")
		self.r = tonumber(r, 16) / div
		self.g = tonumber(g, 16) / div
		self.b = tonumber(b, 16) / div
		self.a = a ~= nil and tonumber(a, 16) / div.a or 1

		-- table with rgb
	elseif value[1] ~= nil then
		self.r = value[1]
		self.g = value[2]
		self.b = value[3]
		self.a = value[4] or self.a or 1
	elseif value.r ~= nil then
		self.r = value.r
		self.g = value.g or self.g
		self.b = value.b or self.b
		self.a = value.a or self.a
	elseif value.c ~= nil then
		local k = 1 - value.k
		self.r = (1 - value.c) * k
		self.g = (1 - value.m) * k
		self.b = (1 - value.y) * k
		self.a = 1

		-- table with hs[vl]
	elseif value.h ~= nil then
		if value.w ~= nil then -- hwb
			value.v = 1 - value.b
			value.s = 1 - value.w / value.v
		end

		local hue, saturation = value.h, value.s
		assert(hue ~= nil, saturation ~= nil)

		local r, g, b = 0, 0, 0

		if value.v ~= nil then
			local v = value.v
			local chroma = saturation * v
			r, g, b = hcm_to_rgb(hue, chroma, v - chroma)
		elseif value.l ~= nil then
			local lightness = value.l
			local chroma = (1 - math.abs(2 * lightness - 1)) * saturation
			r, g, b = hcm_to_rgb(hue, chroma, lightness - chroma / 2)
		end

		self.r = r
		self.g = g
		self.b = b
		self.a = value.a or self.a or 1
	else -- Single set mode
		if value.red then self.r = value.red end
		if value.green then self.g = value.green end
		if value.blue then self.b = value.blue end
		if value.alpha then self.a = value.alpha end

		if value.lightness then
			local h, s, l = self:hsl()
			self:set { h = value.hue or h, s = value.saturation or s, l = value.lightness or l }
			value.hue = nil
			value.saturation = nil
		end

		if value.whiteness or value.blackness then
			local h, w, b = self:hwb()
			self:set { h = value.hue or h, w = value.whiteness or w, b = value.backness or b }
			value.hue = nil
		end

		if value.hue or value.saturation or value.value then
			local h, s, v = self:hsv()
			self:set { h = value.hue or h, s = value.saturation or s, v = value.value or v }
		end

		if value.cyan or value.magenta or value.yellow or value.key then
			local c, m, y, k = self:cmyk()
			self:set {
				c = value.cyan or c,
				m = value.magenta or m,
				y = value.yellow or y,
				k = value.key or k
			}
		end
	end

	local r, g, b, a =
			utils.clamp(self.r, 0, 1),
			utils.clamp(self.g, 0, 1),
			utils.clamp(self.b, 0, 1),
			utils.clamp(self.a, 0, 1)
	assert(r and g and b and a, "Color invalid")
	return self
end

--- Get rgb values.
--
-- @treturn number[0;1] red
-- @treturn number[0;1] green
-- @treturn number[0;1] blue
function Color:rgb()
	return self.r, self.g, self.b
end

--- Get rgba values.
--
-- @treturn number[0;1] red
-- @treturn number[0;1] green
-- @treturn number[0;1] blue
-- @treturn number[0;1] alpha
function Color:rgba()
	return self.r, self.g, self.b, self.a
end

function Color:_hsvm()
	local r, g, b = self.r, self.g, self.b

	local max, max_i = utils.max(r, g, b)
	local min = math.min(r, g, b)
	local chroma = max - min

	local hue
	if chroma == 0 then
		hue = 0
	elseif max_i == 1 then
		hue = ((g - b) / chroma) / 6
	elseif max_i == 2 then
		hue = (2 + (b - r) / chroma) / 6
	elseif max_i == 3 then
		hue = (4 + (r - g) / chroma) / 6
	end

	local saturation = max == 0 and 0 or chroma / max

	return hue % 1, saturation, max, min
end

--- Get hsv values.
--
-- @treturn number[0;1] hue
-- @treturn number[0;1] saturation
-- @treturn number[0;1] value
function Color:hsv()
	local h, s, v = self:_hsvm()
	return h, s, v
end

--- Get hsv values.
--
-- @treturn number[0;1] hue
-- @treturn number[0;1] saturation
-- @treturn number[0;1] value
-- @treturn number[0;1] alpha
function Color:hsva()
	local h, s, v = self:_hsvm()
	return h, s, v, self.a
end

--- Get hsl values.
--
-- @treturn number[0;1] hue
-- @treturn number[0;1] saturation
-- @treturn number[0;1] lightness
function Color:hsl()
	local hue, _, max, min = self:_hsvm()
	local lightness = (max + min) / 2

	local saturation = lightness == 0 and 0
			or (max - lightness) / math.min(lightness, 1 - lightness)

	if saturation ~= saturation then
		saturation = 0
	end

	return hue, saturation, lightness
end

--- Get hsl values.
--
-- @treturn number[0;1] hue
-- @treturn number[0;1] saturation
-- @treturn number[0;1] lightness
-- @treturn number[0;1] alpha
function Color:hsla()
	local h, s, l = self:hsl()
	return h, s, l, self.a
end

--- Get hwb values.
--
-- @treturn number[0;1] hue
-- @treturn number[0;1] whiteness
-- @treturn number[0;1] blackness
function Color:hwb()
	local h, s, v = self:hsv()
	local w = (1 - s) * v
	local b = 1 - v
	return h, w, b
end

--- Get hwb values.
--
-- @treturn number[0;1] hue
-- @treturn number[0;1] whiteness
-- @treturn number[0;1] blackness
-- @treturn number[0;1] alpha
function Color:hwba()
	local h, w, b = self:hwb()
	return h, w, b, self.a
end

--- Get cmyk values.
--
-- @treturn number[0;1] cyan
-- @treturn number[0;1] magenta
-- @treturn number[0;1] yellow
-- @treturn number[0;1] key
function Color:cmyk()
	local r, g, b = self.r, self.g, self.b
	local K = math.max(r, g, b)
	if K == 0 then
		return 0.0, 0.0, 0.0, 1.0
	end
	local k = 1 - K
	local c = (K - r) / K
	local m = (K - g) / K
	local y = (K - b) / K
	return c, m, y, k
end

--- Rotate hue of color.
--
-- @tparam number[0;1]|table value Part of full turn or table containing degree or radians
--
-- @treturn Color self
--
-- @usage color:rotate(0.5)
-- @usage color:rotate {deg=180}
-- @usage color:rotate {rad=math.pi}
function Color:rotate(value)
	local r
	if type(value) == "number" then
		r = value
	elseif value.rad ~= nil then
		r = value.rad / (math.pi * 2)
	elseif value.deg ~= nil then
		r = value.deg / 360
	else
		error("No valid argument")
	end

	local h, s, v = self:hsv()
	h = (h + r) % 1
	self:set { h = h, s = s, v = v, a = self.a }

	return self
end

--- Invert the color.
--
-- @treturn Color self
function Color:invert()
	self.r = 1 - self.r
	self.g = 1 - self.g
	self.b = 1 - self.b
	return self
end

--- Reduce saturation to 0.
--
-- @treturn Color self
function Color:grey()
	local h, _, v = self:hsv()
	self:set { h = h, s = 0, v = v, a = self.a }
	return self
end

--- Set to black or white depending on lightness.
--
-- @tparam ?number[0;1] lightness Cutoff point (Default: 0.5)
--
-- @treturn Color self
function Color:blackOrWhite(lightness)
	local _, _, l = self:hsl()
	local v = l > lightness and 1 or 0
	self.r = v
	self.g = v
	self.b = v
	return self
end

--- Mix two colors together.
--
-- @tparam Color other
-- @tparam ?number strength 0 results in self, 1 results in other (Default: 0.5)
--
-- @treturn Color self
function Color:mix(other, strength)
	if strength == nil then strength = 0.5 end
	self.r = self.r * (1 - strength) + other.r * strength
	self.g = self.g * (1 - strength) + other.g * strength
	self.b = self.b * (1 - strength) + other.b * strength
	self.a = self.a * (1 - strength) + other.a * strength
	return self
end

--- Generate complementary color.
--
-- @treturn Color
function Color:complement()
	return Color(self):rotate(0.5)
end

--- Generate analogous color scheme.
--
-- @treturn Color
-- @treturn Color self
-- @treturn Color
function Color:analogous()
	local h, s, v = self:hsv()
	return Color { h = (h - 1 / 12) % 1, s = s, v = v, a = self.a },
			self,
			Color { h = (h + 1 / 12) % 1, s = s, v = v, a = self.a }
end

--- Generate triadic color scheme.
--
-- @treturn Color self
-- @treturn Color
-- @treturn Color
function Color:triad()
	local h, s, v = self:hsv()
	return self,
			Color { h = (h + 1 / 3) % 1, s = s, v = v, a = self.a },
			Color { h = (h + 2 / 3) % 1, s = s, v = v, a = self.a }
end

--- Generate tetradic color scheme.
--
-- @treturn Color self
-- @treturn Color
-- @treturn Color
-- @treturn Color
function Color:tetrad()
	local h, s, v = self:hsv()
	return self,
			Color { h = (h + 1 / 4) % 1, s = s, v = v, a = self.a },
			Color { h = (h + 2 / 4) % 1, s = s, v = v, a = self.a },
			Color { h = (h + 3 / 4) % 1, s = s, v = v, a = self.a }
end

--- Generate compound color scheme.
--
-- @treturn Color
-- @treturn Color self
-- @treturn Color
function Color:compound()
	local ca, _, cb = self:complement():analogous()
	return ca, self, cb
end

--- Generate evenly spaced color scheme.
-- <br>
-- Generalization of `triad` and `tetrad`.
--
-- @tparam int     n Return n colors
-- @tparam ?number r Space colors over r rotations (Default: 1)
--
-- @treturn {Color,...} Table with n colors including self at index 1
function Color:evenlySpaced(n, r)
	assert(n > 0, "n needs to be greater than 0")
	r = r or 1

	local res = { self }

	local rot = r / n
	local h, s, v = self:hsv()
	local a = self.a

	for _ = 1, n - 1 do
		h = (h + rot) % 1
		table.insert(res, Color { h = h, s = s, v = v, a = a })
	end

	return res
end

--- Get string representation of color.
--
-- If `format` is `nil`, `color:tostring()` is the same as `tostring(color)`.
--
-- @tparam ?string format One of: `#fff`, `#ffff`, `#ffffff`, `#ffffffff`,
--  rgb, rgba, hsv, hsva, hsl, hsla, hwb, hwba, ncol, cmyk
--
-- @treturn string
--
-- @see Color:__tostring
function Color:tostring(format)
	if format == nil then return tostring(self) end

	format = format:lower()

	if format:sub(1, 1) == "#" then
		if #format == 4 then
			return string.format("#%x%x%x", utils.round(self.r * 0xf),
				utils.round(self.g * 0xf), utils.round(self.b * 0xf))
		elseif #format == 5 then
			return string.format("#%x%x%x%x", utils.round(self.r * 0xf),
				utils.round(self.g * 0xf), utils.round(self.b * 0xf), utils.round(self.a * 0xf))
		elseif #format == 7 then
			return string.format("#%02x%02x%02x", utils.round(self.r * 0xff),
				utils.round(self.g * 0xff), utils.round(self.b * 0xff))
		elseif #format == 9 then
			return string.format("#%02x%02x%02x%02x", utils.round(self.r * 0xff),
				utils.round(self.g * 0xff), utils.round(self.b * 0xff), utils.round(self.a * 0xff))
		end
	elseif format == "rgb" then
		return string.format("rgb(%d, %d, %d)",
			utils.round(self.r * 0xff),
			utils.round(self.g * 0xff),
			utils.round(self.b * 0xff))
	elseif format == "rgba" then
		return string.format("rgba(%d, %d, %d, %s)",
			utils.round(self.r * 0xff),
			utils.round(self.g * 0xff),
			utils.round(self.b * 0xff), self.a)
	elseif format == "hsv" then
		local h, s, v = self:hsv()
		return string.format("hsv(%d, %d%%, %d%%)",
			utils.round(h * 360),
			utils.round(s * 100),
			utils.round(v * 100))
	elseif format == "hsva" then
		local h, s, v, a = self:hsva()
		return string.format("hsva(%d, %d%%, %d%%, %s)",
			utils.round(h * 360),
			utils.round(s * 100),
			utils.round(v * 100), a)
	elseif format == "hsl" then
		local h, s, l = self:hsl()
		return string.format("hsl(%d, %d%%, %d%%)",
			utils.round(h * 360),
			utils.round(s * 100),
			utils.round(l * 100))
	elseif format == "hsla" then
		local h, s, l, a = self:hsla()
		return string.format("hsla(%d, %d%%, %d%%, %s)",
			utils.round(h * 360),
			utils.round(s * 100),
			utils.round(l * 100), a)
	elseif format == "hwb" then
		local h, w, b = self:hwb()
		return string.format("hwb(%d, %d%%, %d%%)",
			utils.round(h * 360),
			utils.round(w * 100),
			utils.round(b * 100))
	elseif format == "hwba" then
		local h, w, b, a = self:hwba()
		return string.format("hwba(%d, %d%%, %d%%, %s)",
			utils.round(h * 360),
			utils.round(w * 100),
			utils.round(b * 100), a)
	elseif format == "ncol" then
		local h, w, b = self:hwb()
		local h_maj, h_min = math.modf(h * 6)
		h_maj = h_maj % 6

		local col
		if h_maj == 0 then
			col = "R"
		elseif h_maj == 1 then
			col = "Y"
		elseif h_maj == 2 then
			col = "G"
		elseif h_maj == 3 then
			col = "C"
		elseif h_maj == 4 then
			col = "B"
		else
			col = "M"
		end

		return string.format("%s%d, %d%%, %d%%",
			col, utils.round(h_min * 100),
			utils.round(w * 100),
			utils.round(b * 100))
	elseif format == "cmyk" then
		local c, m, y, k = self:cmyk()
		return string.format("cymk(%d%%, %d%%, %d%%, %d%%)",
			utils.round(c * 100),
			utils.round(m * 100),
			utils.round(y * 100),
			utils.round(k * 100))
	end

	return tostring(self)
end

--- Get color in rgb hex notation.
-- <br>
-- only adds alpha value if `color.a < 1`
--
-- @treturn string `#rrggbb` | `#rrggbbaa`
--
-- @see Color:tostring
function Color:__tostring()
	if self.a < 1 then
		return string.format(
			"#%02x%02x%02x%02x",
			utils.round(self.r * 0xff),
			utils.round(self.g * 0xff),
			utils.round(self.b * 0xff),
			utils.round(self.a * 0xff)
		)
	else
		return string.format(
			"#%02x%02x%02x",
			utils.round(self.r * 0xff),
			utils.round(self.g * 0xff),
			utils.round(self.b * 0xff)
		)
	end
end

--- Check if colors are equal.
--
-- @tparam Color other
--
-- @treturn boolean all values are equal
function Color:__eq(other)
	return self.r == other.r
			and self.g == other.g
			and self.b == other.b
			and self.a == other.a
end

--- Checks whether color is darker.
--
-- @tparam Color other
--
-- @treturn boolean self is darker than other
function Color:__lt(other)
	local _, _, la = self:hsl()
	local _, _, lb = other:hsl()
	return la < lb
end

--- Checks whether color is as dark or darker.
--
-- @tparam Color other
--
-- @treturn boolean self is as dark or darker than other
function Color:__le(other)
	local _, _, la = self:hsl()
	local _, _, lb = other:hsl()
	return la <= lb
end

--- Iterate through color.
--
-- Iterates through r, g, b, and a.
function Color:__pairs()
	local function iter(_, k)
		if k == nil then
			return "r", self.r
		elseif k == "r" then
			return "g", self.g
		elseif k == "g" then
			return "b", self.b
		elseif k == "b" then
			return "a", self.a
		end
	end

	return iter, self, nil
end

--- Get inverted clone of color.
--
-- @treturn Color
function Color:__unm()
	return Color(self):invert()
end

--- Mix two colors evenly.
--
-- @tparam Color a first color
-- @tparam Color b second color
--
-- @treturn Color new color
--
-- @see Color:mix
function Color.__add(a, b)
	assert(Color.isColor(a) and Color.isColor(b), "Can only add two colors.")
	return Color(a):mix(b)
end

--- Complement of even mix.
--
-- @tparam Color a first color
-- @tparam Color b second color
--
-- @treturn Color new color
--
-- @see Color:mix
-- @see Color.__add
function Color.__sub(a, b)
	assert(Color.isColor(a) and Color.isColor(b), "Can only add two colors.")
	return Color(a):mix(b):rotate(0.5)
end

--- Apply rgb mask to color.
--
-- @tparam Color|number a color or mask
-- @tparam Color|number b color or mask (if a and b are colors b is used as mask)
--
-- @treturn Color new color
--
-- @usage local new_col = color & 0xff00ff -- get new color without the green channel
function Color.__band(a, b)
	local color, mask
	if Color.isColor(a) and type(b) == "number" then
		color = a
		mask = b
	elseif Color.isColor(b) and type(a) == "number" then
		color = b
		mask = a
	elseif Color.isColor(a) and Color.isColor(b) then
		color = a
		mask = bit_lshift(utils.round(b.r * 0xff), 16)
				+ bit_lshift(utils.round(b.g * 0xff), 8)
				+ utils.round(b.b * 0xff)
	else
		error("Required arguments: Color|number,Color|number Received: " .. type(a) .. "," .. type(b))
	end

	return Color {
		bit_and(utils.round(color.r * 0xff), bit_rshift(mask, 16)) / 0xff,
		bit_and(utils.round(color.g * 0xff), bit_rshift(mask, 8)) / 0xff,
		bit_and(utils.round(color.b * 0xff), mask) / 0xff,
		color.a
	}
end

--- Apply rgb mask to color, providing backwards compatibility for Lua 5.1 and LuaJIT 2.1.0-beta3 (e.g. inside Neovim), which don't provide native support for bitwise operators.
--
-- @tparam Color|number a color or mask
-- @tparam Color|number b color or mask (if a and b are colors b is used as mask)
--
-- @treturn Color new color
--
-- @usage local new_col = Color.band(color, 0xff00ff) -- get new color without the green channel
function Color.band(a, b)
	return Color.__band(a, b)
end

--- Check whether `color` is a Color.
--
-- @param color
--
-- @treturn boolean is a color
--
-- @usage if Color.isColor(color) then print "It's a color!" end
function Color.isColor(color)
	return color ~= nil and color.__is_color == true
end

return Color
