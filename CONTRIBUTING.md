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

To create a custom theme you need to define a colorscheme for each of vim's modes. Each mode has a `fg` and `bg` field for every lualine section.
You can add special effects with `gui`.
You can provide colors in two ways
  1. As a table like `{'hexcode', 256_color_code}`
  2. As a String like `'hexcode'`
Note : You can use table `lualine.util.color_table` to genarate 256_color_codes from hex_codes.
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
  -- gui parameter is optional and behaves the same way as in vim's highlight command
  a = { bg = colors.gray, fg = colors.black, gui = "bold", },
  b = { bg = colors.lightgray, fg  = colors.white, },
  c = { bg = colors.darkgray, fg = colors.gray }
}

gruvbox.insert = {
  a = { bg = colors.blue, fg = colors.black, gui = "bold", },
  b = { bg = colors.lightgray, fg = colors.white, },
  c = { bg = colors.lightgray, fg = colors.white }
}


gruvbox.visual = {
  a = { bg = colors.yellow, fg = colors.black, gui = "bold", },
  b = { bg = colors.lightgray, fg = colors.white, },
  c = { bg = colors.inactivegray, fg = colors.black },
}

gruvbox.replace = {
  a = { bg = colors.red, fg = colors.black, gui = "bold", },
  b = { bg = colors.lightgray, fg = colors.white, },
  c = { bg = colors.black, fg = colors.white },
}

gruvbox.command = {
  a = { bg = colors.green, fg = colors.black, gui = "bold", },
  b = { bg = colors.lightgray, fg = colors.white, },
  c = { bg = colors.inactivegray, fg = colors.black },
}

-- you can assign one colorscheme to another, if a colorscheme is
-- undefined it falls back to normal
gruvbox.terminal = gruvbox.normal

gruvbox.inactive = {
  a = { bg = colors.darkgray, fg = colors.gray, gui = "bold", },
  b = { bg = colors.darkgray, fg = colors.gray, },
  c = { bg = colors.darkgray, fg = colors.gray },
}

lualine.theme = gruvbox
```

</details>

### Adding an extension

* add your extension with screenshots attached to [EXTENSIONS.md](./EXTENSIONS.md) while maintaining alphabetical order
