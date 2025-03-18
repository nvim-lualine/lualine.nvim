---
-- Get color names from files.
--
-- @see Color.colorNames

--- Load table from file.
--
-- Uses `[:,;=]` as separator.
-- Lines that do not match the pattern are ignored.
-- Only the first occurence of the separator is parsed, other occurences are ignored.
-- <br>
-- Some valid formats are:<ul>
--  <li>`color name: #ff0000`</li>
--  <li>`color name,rgba(88, 70, 30, .9)`</li>
--  <li>`color name;another color name in this file` (recursive or circular naming will cause a crash)</li>
--  <li>`color name = #fffa`</li>
-- </ul>
--
-- @tparam string|file file Filename or open file descriptor
--
-- @treturn {[string]=string,...}
--
-- @usage Color.colorNames = colors.load "my-colors.yaml"
-- @usage local colors_file = assert(io.open("my-colors.conf", "r"))
-- Color.colorNames = colors.load(colors_file)
-- colors_file:close()
local function load(file)
  local res = {}

  local f = type(file) == "string" and io.open(file, "r") or file
  while true do
    local line = f:read()
    if line == nil then break end

    local name, value = line:match "^%s*([^:,;=]+)%s*[:,;=]%s*(.+)%s*$"
    if name ~= nil and value ~= nil then
      res[name] = value
    end
  end

  return res
end

--- Load table from csv file.
--
-- @tparam string|file file Filename or open file descriptor
-- @tparam ?int        nameColumn  Column index for the name (Default: 1)
-- @tparam ?int|table  valueColumn Column index for the value (Default: 2)
--  or table with column indices (and optionally divisors) for the color components
-- @tparam ?string     separator   Column separator (Default: `,;`)
-- @tparam ?bool       skipFirst   Skip first line (Default: `false`)
--
-- @treturn {[string]=string,...}
--
-- @usage -- csv file: red,rgb 255 0 0
-- Color.colorNames = colors.loadCsv "my-colors.csv"
--
-- @usage -- csv file: red,red is a color,255,0,0,0.5
-- Color.colorNames = colors.loadCsv("my-colors.csv", 1, {
--   r = {3, 255}, -- load red component from column 3 and divide by 255
--   g = {4, 255},
--   b = {5, 255},
--   a = 6 -- load alpha from column 6 (value is in [0;1] => no division required)
-- })
local function loadCsv(file, nameColumn, valueColumn, separator, skipFirst)
  nameColumn = nameColumn or 1
  valueColumn = valueColumn or 2

  local res = {}
  local pattern = "[^"..(separator or ",;").."]*"
  local columnIsNum = true

  if type(valueColumn) ~= "number" then
    columnIsNum = false
    for comp, val in pairs(valueColumn) do
      if type(val) == "number" then
        valueColumn[comp] = {val}
      end
    end
  end

  local f = type(file) == "string" and io.open(file, "r") or file
  while true do
    local line = f:read()
    if line == nil then break end
    if skipFirst then
      skipFirst = false
      goto endloop
    end


    local name
    local value = {}
    local col = 1
    for field in line:gmatch(pattern) do
      if col == nameColumn then
        name = field
      elseif columnIsNum then
        if col == valueColumn then value = field end
      else
        for component, cconf in pairs(valueColumn) do
          if col == cconf[1] then
            local fieldVal = tonumber(field)
            value[component] = #cconf > 1 and fieldVal / cconf[2] or fieldVal
            valueColumn[component] = nil
          end
        end
      end

      col = col + 1
    end

    res[name] = value

    ::endloop::
  end

  return res
end

--- @export
return {
  load = load,
  loadCsv = loadCsv
}
