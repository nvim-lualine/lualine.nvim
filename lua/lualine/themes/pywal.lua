local wal_colors_file = io.open(os.getenv("HOME") .. "/.cache/wal/colors.sh", "r")

if wal_colors_file == nil then
  vim.api.nvim_command('echohl ErrorMsg | echo "lightline.lua: ~/.config/wal/colors.sh could not be read" | echohl None')
  error("")
end

local colors = {}
local curr_line = wal_colors_file:read()

while curr_line ~= nil do
  if curr_line:match('^[a-z0-9]+=\'#[a-f0-9]+\'') then
    local div = curr_line:find('=')
    local key = curr_line:sub(0, div - 1)
    local value = curr_line:sub(div + 2, #curr_line - 1)
    table.insert(colors, key)
    colors[key] = value
  end
  curr_line = wal_colors_file:read()
end

return {
  normal = {
    a = {fg = colors.background, bg = colors.color4, gui = 'bold'},
    b = {fg = colors.foreground, bg = colors.color8},
    c = {fg = colors.foreground, bg = colors.background}
  },
  insert = {a = {fg = colors.background, bg = colors.color2, gui = 'bold'}},
  visual = {a = {fg = colors.background, bg = colors.color3, gui = 'bold'}},
  replace = {a = {fg = colors.background, bg = colors.color1, gui = 'bold'}},
  inactive = {
    a = {fg = colors.foreground, bg = colors.background, gui = 'bold'},
    b = {fg = colors.foreground, bg = colors.background},
    c = {fg = colors.foreground, bg = colors.background}
  }
}
