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
This is really easy in lua. Here is and example of a gruvbox theme.

```lua
local gruvbox = {  }

local colors = {
  black = "#282828",
  white = '#ebdbb2',
  red = '#fb4934',
  green = '#b8bb26',
  blue = '#83a598',
  yellow = '#fe8019',

  gray = '#a89984',
  darkgray = '#3c3836',

  lightgray = '#504945',
  inactivegray = '#7c6f64',
}

gruvbox.normal = {
  a = {
    bg = colors.gray,
    fg = colors.black,
  },
  b = {
    bg = colors.lightgray,
    fg  = colors.white,
  },
  c = {
    bg = colors.darkgray,
    fg = colors.gray
  }
}

gruvbox.insert = {
  a = {
    bg = colors.blue,
    fg = colors.black,
  },
  b = {
    bg = colors.lightgray,
    fg = colors.white,
  },
  c = {
    bg = colors.lightgray,
    fg = colors.white
  }
}


gruvbox.visual = {
  a = {
    bg = colors.yellow,
    fg = colors.black,
  },
  b = {
    bg = colors.lightgray,
    fg = colors.white,
  },
  c = {
    bg = colors.inactivegray,
    fg = colors.black
  },
}

gruvbox.replace = {
  a = {
    bg = colors.red,
    fg = colors.black,
  },
  b = {
    bg = colors.lightgray,
    fg = colors.white,
  },
  c = {
    bg = colors.black,
    fg = colors.white
  },
}

gruvbox.command = {
  a = {
    bg = colors.green,
    fg = colors.black,
  },
  b = {
    bg = colors.lightgray,
    fg = colors.white,
  },
  c = {
    bg = colors.inactivegray,
    fg = colors.black
  },
}

gruvbox.terminal = gruvbox.normal

gruvbox.inactive = {
  a = {
    bg = colors.darkgray,
    fg = colors.gray,
  },
  b = {
    bg = colors.darkgray,
    fg = colors.gray,
  },
  c = {
    bg = colors.darkgray,
    fg = colors.gray
  },
}

lualine.theme = gruvbox
```

</details>

### Adding an extension

* add your extension with screenshots attached to [EXTENSIONS.md](./EXTENSIONS.md) while maintaining alphabetical order
