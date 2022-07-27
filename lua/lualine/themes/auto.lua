-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local utils = require('lualine.utils.utils')
local loader = require('lualine.utils.loader')

local color_name = vim.g.colors_name
if color_name then
  -- All base16 colorschemes share the same theme
  if 'base16' == color_name:sub(1, 6) then
    color_name = 'base16'
  end

  -- Check if there's a theme for current colorscheme
  -- If there is load that instead of generating a new one
  local ok, theme = pcall(loader.load_theme, color_name)
  if ok and theme then
    return theme
  end
end

---------------
-- Constants --
---------------
-- fg and bg must have this much contrast range 0 < contrast_threshold < 0.5
local contrast_threshold = 0.3
-- how much brightness is changed in percentage for light and dark themes
local brightness_modifier_parameter = 10

-- Turns #rrggbb -> { red, green, blue }
local function rgb_str2num(rgb_color_str)
  if rgb_color_str:find('#') == 1 then
    rgb_color_str = rgb_color_str:sub(2, #rgb_color_str)
  end
  local red = tonumber(rgb_color_str:sub(1, 2), 16)
  local green = tonumber(rgb_color_str:sub(3, 4), 16)
  local blue = tonumber(rgb_color_str:sub(5, 6), 16)
  return { red = red, green = green, blue = blue }
end

-- Turns { red, green, blue } -> #rrggbb
local function rgb_num2str(rgb_color_num)
  local rgb_color_str = string.format('#%02x%02x%02x', rgb_color_num.red, rgb_color_num.green, rgb_color_num.blue)
  return rgb_color_str
end

-- Returns brightness level of color in range 0 to 1
-- arbitrary value it's basically an weighted average
local function get_color_brightness(rgb_color)
  local color = rgb_str2num(rgb_color)
  local brightness = (color.red * 2 + color.green * 3 + color.blue) / 6
  return brightness / 256
end

-- returns average of colors in range 0 to 1
-- used to determine contrast level
local function get_color_avg(rgb_color)
  local color = rgb_str2num(rgb_color)
  return (color.red + color.green + color.blue) / 3 / 256
end

-- Clamps the val between left and right
local function clamp(val, left, right)
  if val > right then
    return right
  end
  if val < left then
    return left
  end
  return val
end

-- Changes brightness of rgb_color by percentage
local function brightness_modifier(rgb_color, parcentage)
  local color = rgb_str2num(rgb_color)
  color.red = clamp(color.red + (color.red * parcentage / 100), 0, 255)
  color.green = clamp(color.green + (color.green * parcentage / 100), 0, 255)
  color.blue = clamp(color.blue + (color.blue * parcentage / 100), 0, 255)
  return rgb_num2str(color)
end

-- Changes contrast of rgb_color by amount
local function contrast_modifier(rgb_color, amount)
  local color = rgb_str2num(rgb_color)
  color.red = clamp(color.red + amount, 0, 255)
  color.green = clamp(color.green + amount, 0, 255)
  color.blue = clamp(color.blue + amount, 0, 255)
  return rgb_num2str(color)
end

-- Changes brightness of foreground color to achieve contrast
-- without changing the color
local function apply_contrast(highlight)
  local hightlight_bg_avg = get_color_avg(highlight.bg)
  local contrast_threshold_config = clamp(contrast_threshold, 0, 0.5)
  local contranst_change_step = 5
  if hightlight_bg_avg > 0.5 then
    contranst_change_step = -contranst_change_step
  end

  -- Don't waste too much time here max 25 iteration should be more than enough
  local iteration_count = 1
  while
    math.abs(get_color_avg(highlight.fg) - hightlight_bg_avg) < contrast_threshold_config and iteration_count < 25
  do
    highlight.fg = contrast_modifier(highlight.fg, contranst_change_step)
    iteration_count = iteration_count + 1
  end
end

-- Get the colors to create theme
-- stylua: ignore
local colors = {
  normal  = utils.extract_color_from_hllist('bg', { 'PmenuSel', 'PmenuThumb', 'TabLineSel' }, '#000000'),
  insert  = utils.extract_color_from_hllist('fg', { 'String', 'MoreMsg' }, '#000000'),
  replace = utils.extract_color_from_hllist('fg', { 'Number', 'Type' }, '#000000'),
  visual  = utils.extract_color_from_hllist('fg', { 'Special', 'Boolean', 'Constant' }, '#000000'),
  command = utils.extract_color_from_hllist('fg', { 'Identifier' }, '#000000'),
  back1   = utils.extract_color_from_hllist('bg', { 'Normal', 'StatusLineNC' }, '#000000'),
  fore    = utils.extract_color_from_hllist('fg', { 'Normal', 'StatusLine' }, '#000000'),
  back2   = utils.extract_color_from_hllist('bg', { 'StatusLine' }, '#000000'),
}

-- Change brightness of colors
-- Darken if light theme (or) Lighten if dark theme
local normal_color = utils.extract_highlight_colors('Normal', 'bg')
if normal_color ~= nil then
  if get_color_brightness(normal_color) > 0.5 then
    brightness_modifier_parameter = -brightness_modifier_parameter
  end
  for name, color in pairs(colors) do
    colors[name] = brightness_modifier(color, brightness_modifier_parameter)
  end
end

-- Basic theme definition
local M = {
  normal = {
    a = { bg = colors.normal, fg = colors.back1, gui = 'bold' },
    b = { bg = colors.back1, fg = colors.normal },
    c = { bg = colors.back2, fg = colors.fore },
  },
  insert = {
    a = { bg = colors.insert, fg = colors.back1, gui = 'bold' },
    b = { bg = colors.back1, fg = colors.insert },
    c = { bg = colors.back2, fg = colors.fore },
  },
  replace = {
    a = { bg = colors.replace, fg = colors.back1, gui = 'bold' },
    b = { bg = colors.back1, fg = colors.replace },
    c = { bg = colors.back2, fg = colors.fore },
  },
  visual = {
    a = { bg = colors.visual, fg = colors.back1, gui = 'bold' },
    b = { bg = colors.back1, fg = colors.visual },
    c = { bg = colors.back2, fg = colors.fore },
  },
  command = {
    a = { bg = colors.command, fg = colors.back1, gui = 'bold' },
    b = { bg = colors.back1, fg = colors.command },
    c = { bg = colors.back2, fg = colors.fore },
  },
}

M.terminal = M.command
M.inactive = M.normal

-- Apply proper contrast so text is readable
for _, section in pairs(M) do
  for _, highlight in pairs(section) do
    apply_contrast(highlight)
  end
end

return M
