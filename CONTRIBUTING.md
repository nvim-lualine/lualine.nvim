# Contributing to lualine.nvim


### General

please use lua-format before creating a pr :smile:

### All contributions are very welcome but themes require a lot of work on my part if not done properly so here's a guide on how to do them.

### Adding a theme

* refer to example below to see how themes are defined
* take 4 screenshots showing a different vim modes (normal, insert, visual, replace)
* add your theme with screenshots attached to [THEMES.md](./THEMES.md) while maintaining alphabetical order
* If the colorscheme you're trying to add already support lightline. You can use
[lightline2lualine theme converter](https://gist.github.com/shadmansaleh/000871c9a608a012721c6acc6d7a19b9) to easily port the theme to lualine.

**Note to colorscheme authors** : If you want to support lualine. You can put your
lualine theme at lua/lualine/themes/{your_colorscheme}.lua in you repo.

<details>
<summary><b>theme example</b></summary>

To create a custom theme you need to define a colorscheme for each of vim's modes. Each mode has a `fg` and `bg` field for every lualine section.
You can add special effects with `gui`.

Adding theme is really easy in lua. Here is and example of a gruvbox theme.

```lua
local gruvbox = {  }

local colors = {
  black        = "#282828",
  white        = '#ebdbb2',
  red          = '#fb4934',
  green        = '#b8bb26',
  blue         = '#83a598',
  yellow       = '#fe8019',
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

require('lualine').setup {options = {theme = gruvbox}}
```

</details>
