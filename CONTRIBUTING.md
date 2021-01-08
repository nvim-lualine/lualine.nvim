# Contributing to lualine.nvim


### General

* 2 spaces
* snake_case

### All contributions are very welcome but themes/ extensions require a lot of work on my part if not done properly so here's a guide on how to do them.

### Adding a theme

* refer to example below to see how themes are defined
* take 4 screenshots showing a different vim modes (normal, insert, visual, replace)
* add your theme with screenshots attached to [THEMES.md](./THEMES.md) while maintaining alphabetical order

<details>
<summary><b>theme example</b></summary>

To create a custom theme you need to define a colorscheme for each of vim's modes. Each mode has a dictionary structured like `{ forground_color, background_color, special_effect}` for every lualine section.
The special_effect perameter is optional.
You can see list of supportted special_efects with `:help highlight-cterm`.
You can provide colors in two ways
  1. As a table like `{'hexcode', 256_color_code}`
  2. As a String like `'hexcode'`
Note : You can use `lualine.util.get_cterm_color(hex_color)` function to genarate 256_color_codes from hex_codes.
  When method 2 is used 256_color_codes are genarated with that .

Adding theme is really easy in lua. Here is and example of a gruvbox theme.

```lua
local gruvbox = {  }

local colors = {
 -- color format { hex_color, 256_color_code}
  black        = {"#282828", 235},
  white        = {'#ebdbb2', 223},
  red          = {'#fb4934', 203},
  green        = {'#b8bb26', 143},
  blue         = {'#83a598', 108},
  yellow       = {'#fe8019', 209},

  -- color format 'hex_color'
  gray         = '#a89984',
  darkgray     = '#3c3836',
  lightgray    = '#504945',
  inactivegray = '#7c6f64',
}

gruvbox.normal = {
  a = { colors.black, colors.gray, 'bold', },
  b = { colors.white, colors.lightgray, },
  c = { colors.gray , colors.darkgray}
}

gruvbox.insert = {
  a = { colors.black, colors.blue, 'bold', },
  b = { colors.white, colors.lightgray, },
  c = { colors.white , colors.lightgray}
}


gruvbox.visual = {
  a = { colors.black, colors.yellow, 'bold', },
  b = { colors.white, colors.lightgray, },
  c = { colors.black , colors.inactivegray},
}

gruvbox.replace = {
  a = { colors.black, colors.red, 'bold', },
  b = { colors.white, colors.lightgray, },
  c = { colors.white , colors.black},
}

gruvbox.command = {
  a = { colors.black, colors.green, 'bold', },
  b = { colors.white, colors.lightgray, },
  c = { colors.black , colors.inactivegray},
}

-- you can assign one colorscheme to another, if a colorscheme is
-- undefined it falls back to normal
gruvbox.terminal = gruvbox.normal

gruvbox.inactive = {
  a = { colors.gray, colors.darkgray, 'bold', },
  b = { colors.gray, colors.darkgray, },
  c = { colors.gray , colors.darkgray},
}

lualine.theme = gruvbox
```

</details>

### Adding an extension

* add your extension with screenshots attached to [EXTENSIONS.md](./EXTENSIONS.md) while maintaining alphabetical order
