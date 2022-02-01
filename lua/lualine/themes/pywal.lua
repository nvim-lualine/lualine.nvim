-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require {
  utils_notices = 'lualine.utils.notices',
}
local sep = package.config:sub(1, 1)
local wal_colors_path = table.concat({ os.getenv('HOME'), '.cache', 'wal', 'colors.sh' }, sep)
local wal_colors_file = io.open(wal_colors_path, 'r')

if wal_colors_file == nil then
  modules.utils_notices.add_notice('lualine.nvim: ' .. wal_colors_path .. ' not found')
  error('')
end

local ok, wal_colors_text = pcall(wal_colors_file.read, wal_colors_file, '*a')
wal_colors_file:close()

if not ok then
  modules.utils_notices.add_notice('lualine.nvim: ' .. wal_colors_path .. ' could not be read: ' .. wal_colors_text)
  error('')
end

local colors = {}

for line in vim.gsplit(wal_colors_text, '\n') do
  if line:match("^[a-z0-9]+='#[a-fA-F0-9]+'$") ~= nil then
    local i = line:find('=')
    local key = line:sub(0, i - 1)
    local value = line:sub(i + 2, #line - 1)
    colors[key] = value
  end
end

return {
  normal = {
    a = { fg = colors.background, bg = colors.color4, gui = 'bold' },
    b = { fg = colors.foreground, bg = colors.color8 },
    c = { fg = colors.foreground, bg = colors.background },
  },
  insert = { a = { fg = colors.background, bg = colors.color2, gui = 'bold' } },
  visual = { a = { fg = colors.background, bg = colors.color3, gui = 'bold' } },
  replace = { a = { fg = colors.background, bg = colors.color1, gui = 'bold' } },
  inactive = {
    a = { fg = colors.foreground, bg = colors.background, gui = 'bold' },
    b = { fg = colors.foreground, bg = colors.background },
    c = { fg = colors.foreground, bg = colors.background },
  },
}
