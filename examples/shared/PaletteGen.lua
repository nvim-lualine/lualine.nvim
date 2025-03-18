local M = {}
local Color = require("shared.lua-color")

-- Function to read colors from the wal color file
function M.read_wal_colors()
  local colors = {}
  local seen = {}
  local color_file = os.getenv("HOME") .. "/.cache/wal/colors"

  local file = io.open(color_file, "r")
  if file then
    for line in file:lines() do
      if not seen[line] and line ~= "" then
        local color_obj = Color(line)
        local color_hex = color_obj:tostring("hex")
        if not seen[color_hex] then
          table.insert(colors, color_obj)
          seen[color_hex] = true
        end
      end
    end
    file:close()
  end

  return colors
end

-- Function to generate a color palette
function M.generate_palette(base_colors, total_colors)
  local palette = {}
  local generated_colors = {}

  -- Helper function to add unique colors to the palette
  local function add_unique_color(color)
    local hex = color:tostring("hex")
    if not generated_colors[hex] then
      table.insert(palette, color)
      generated_colors[hex] = true
    end
  end

  -- First, add all unique base colors from wal
  for _, base_color in ipairs(base_colors) do
    add_unique_color(base_color)
  end

  -- If we already have enough colors, return the palette
  if #palette >= total_colors then
    return palette
  end

  -- List of color scheme generation functions
  local color_schemes = {
    function(color) return { color:complement() } end, -- Complementary
    function(color) return { color:analogous() } end,  -- Analogous (returns 3 colors)
    function(color) return { color:triad() } end,      -- Triadic (returns 3 colors)
    function(color) return { color:tetrad() } end,     -- Tetradic (returns 4 colors)
    function(color) return { color:compound() } end,   -- Compound (returns 3 colors)
  }

  -- Randomize the order of base_colors
  local shuffled_base_colors = {}
  for i = 1, #base_colors do
    shuffled_base_colors[i] = base_colors[i]
  end
  for i = #shuffled_base_colors, 2, -1 do
    local j = math.random(i)
    shuffled_base_colors[i], shuffled_base_colors[j] = shuffled_base_colors[j], shuffled_base_colors[i]
  end

  -- Seed the random number generator
  math.randomseed(os.time())

  -- Use a while loop to keep generating colors until the palette is full
  while #palette < total_colors do
    -- Randomly select a base color
    local base_color = shuffled_base_colors[math.random(#shuffled_base_colors)]

    -- Randomly select a color scheme
    local scheme = color_schemes[math.random(#color_schemes)]
    local new_colors = scheme(base_color)

    -- Add the generated colors to the palette
    for _, col in ipairs(new_colors) do
      add_unique_color(col)
      if #palette >= total_colors then
        break
      end
    end
  end

  return palette
end

-- Function to convert generated Color objects to strings (hex)
function M.colors_to_strings(colors)
  local color_strings = {}
  for _, color in ipairs(colors) do
    table.insert(color_strings, color:tostring("hex"))
  end
  return color_strings
end

return M
