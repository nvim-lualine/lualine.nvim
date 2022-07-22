# lualine.nvim

<!-- panvimdoc-ignore-start -->

![code size](https://img.shields.io/github/languages/code-size/nvim-lualine/lualine.nvim?style=flat-square)
![license](https://img.shields.io/github/license/nvim-lualine/lualine.nvim?style=flat-square)

<!-- panvimdoc-ignore-end -->

A blazing fast and easy to configure Neovim statusline written in Lua.

`lualine.nvim` requires Neovim >= 0.5.

## Contributing

Feel free to create an issue/PR if you want to see anything else implemented.
If you have some question or need help with configuration, start a [discussion](https://github.com/nvim-lualine/lualine.nvim/discussions).

Please read [CONTRIBUTING.md](./CONTRIBUTING.md) before opening a PR.
You can also help with documentation in the [wiki](https://github.com/nvim-lualine/lualine.nvim/wiki).

<!-- panvimdoc-ignore-start -->

## Screenshots

Here is a preview of what lualine can look like.

<p>
<img width='700' src='https://user-images.githubusercontent.com/41551030/108650373-bb025580-74bf-11eb-8682-2c09321dd18e.png'/>
<img width='700' src='https://user-images.githubusercontent.com/41551030/108650377-bd64af80-74bf-11eb-9c55-fbfc51b39fe8.png'/>
<img width='700' src='https://user-images.githubusercontent.com/41551030/108650378-be95dc80-74bf-11eb-9718-82b242ecdd54.png'/>
<img width='700' src='https://user-images.githubusercontent.com/41551030/108650381-bfc70980-74bf-11eb-9245-85c48f0f154a.png'/>
<img width='700' src='https://user-images.githubusercontent.com/41551030/103467925-32372b00-4d54-11eb-88d6-6d39c46854d8.png'/>
</p>

Screenshots of all available themes are listed in [THEMES.md](./THEMES.md)

For those who want to break the norms, you can create custom looks for lualine.

**Example** :

- [evil_lualine](examples/evil_lualine.lua)
  <img width='700' src='https://user-images.githubusercontent.com/13149513/113875129-4453ba00-97d8-11eb-8f21-94a9ef565db3.png'/>
- [slanted-gaps](examples/slanted-gaps.lua)
  <img width='700' src='https://user-images.githubusercontent.com/13149513/143395518-f6d6f748-c1ca-491b-9dab-246d0a8cf23f.png'/>
- [bubbles](examples/bubbles.lua)
  <img width='700' src='https://user-images.githubusercontent.com/20235646/131350468-fc556196-5f46-4bfe-a72e-960f6a58db2c.png'/>

<!-- panvimdoc-ignore-end -->

## Performance compared to other plugins

Unlike other statusline plugins, lualine loads only the components you specify, and nothing else.

Startup time performance measured with an amazing plugin [dstein64/vim-startuptime](https://github.com/dstein64/vim-startuptime)

Times are measured with a clean `init.vim` with only `vim-startuptime`,
`vim-plug` and given statusline plugin installed.
In control just `vim-startuptime` and`vim-plug` is installed.
And measured time is complete startuptime of vim not time spent
on specific plugin. These numbers are the average of 20 runs.

| control  |  lualine  | lightline |  airline  |
| :------: | :-------: | :-------: | :-------: |
| 17.2 ms  |  24.8 ms  |  25.5 ms  |  79.9 ms  |

Last Updated On: 18-04-2022

## Installation

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-lualine/lualine.nvim'
" If you want to have icons in your statusline choose one of these
Plug 'kyazdani42/nvim-web-devicons'
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'nvim-lualine/lualine.nvim',
  requires = { 'kyazdani42/nvim-web-devicons', opt = true }
}
```

You'll also need to have a patched font if you want icons.

## Usage and customization

Lualine has sections as shown below.

```text
+-------------------------------------------------+
| A | B | C                             X | Y | Z |
+-------------------------------------------------+
```

Each sections holds its components e.g. Vim's current mode.

### Configuring lualine in init.vim

All the examples below are in lua. You can use the same examples
in `.vim` files by wrapping them in lua heredoc like this:

```vim
lua << END
require('lualine').setup()
END
```

For more information, check out `:help lua-heredoc`.

#### Default configuration

```lua
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
    globalstatus = false,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}
```

If you want to get your current lualine config, you can
do so with:

```lua
require('lualine').get_config()

```

---

### Starting lualine

```lua
require('lualine').setup()
```

---

### Setting a theme

```lua
options = { theme = 'gruvbox' }
```

All available themes are listed in [THEMES.md](./THEMES.md).

Please create a PR if you managed to port a popular theme before us, [here is how to do it](./CONTRIBUTING.md).

#### Customizing themes

```lua
local custom_gruvbox = require'lualine.themes.gruvbox'

-- Change the background of lualine_c section for normal mode
custom_gruvbox.normal.c.bg = '#112233'

require('lualine').setup {
  options = { theme  = custom_gruvbox },
  ...
}
```

Theme structure is available [here](https://github.com/nvim-lualine/lualine.nvim/wiki/Writing-a-theme).

---

### Separators

lualine defines two kinds of separators:

- `section_separators`    - separators between sections
- `component_separators` - separators between the different components in sections

**Note**: if viewing this README in a browser, chances are the characters below will not be visible.

```lua
options = {
  section_separators = { left = '', right = '' },
  component_separators = { left = '', right = '' }
}
```

Here, left refers to the left-most sections (a, b, c), and right refers
to the right-most sections (x, y, z).

#### Disabling separators

```lua
options = { section_separators = '', component_separators = '' }
```

---

### Changing components in lualine sections

```lua
sections = {lualine_a = {'mode'}}
```

#### Available components

- `branch` (git branch)
- `buffers` (shows currently available buffers)
- `diagnostics` (diagnostics count from your preferred source)
- `diff` (git diff status)
- `encoding` (file encoding)
- `fileformat` (file format)
- `filename`
- `filesize`
- `filetype`
- `hostname`
- `location` (location in file in line:column format)
- `mode` (vim mode)
- `progress` (%progress in file)
- `tabs` (shows currently available tabs)
- `windows` (shows currently available windows)

#### Custom components

##### Lua functions as lualine component

```lua
local function hello()
  return [[hello world]]
end
sections = { lualine_a = { hello } }
```

##### Vim functions as lualine component

```lua
sections = { lualine_a = {'FugitiveHead'} }
```

##### Vim's statusline items as lualine component

```lua
sections = { lualine_c = {'%=', '%t%m', '%3p'} }
```

##### Vim variables as lualine component

Variables from `g:`, `v:`, `t:`, `w:`, `b:`, `o`, `go:`, `vo:`, `to:`, `wo:`, `bo:` scopes can be used.

See `:h lua-vim-variables` and `:h lua-vim-options` if you are not sure what to use.

```lua
sections = { lualine_a = { 'g:coc_status', 'bo:filetype' } }
```

##### Lua expressions as lualine component

You can use any valid lua expression as a component including:
- oneliners
- global variables
- require statements

```lua
sections = { lualine_c = { "os.date('%a')", 'data', "require'lsp-status'.status()" } }
```

`data` is a global variable in this example.

---

### Component options

Component options can change the way a component behave.
There are two kinds of options:

- global options affecting all components
- local options affecting specific

Global options can be used as local options (can be applied to specific components)
but you cannot use local options as global.
Global option used locally overwrites the global, for example:

```lua
    require('lualine').setup {
      options = { fmt = string.lower },
      sections = { lualine_a = {
        { 'mode', fmt = function(str) return str:sub(1,1) end } },
                  lualine_b = {'branch'} }
    }
```

`mode` will be formatted with the passed function so only first char will be
shown . On the other hand branch will be formatted with global formatter
`string.lower` so it will be showed in lower case.

#### Available options

#### Global options

These are `options` that are used in options table.
They set behavior of lualine.

Values set here are treated as default for other options
that work in component level.

For example even though `icons_enabled` is a general component option.
you can set `icons_enabled` to `false` and icons will be disabled on all
component. You can still overwrite defaults set in option table by specifying
the option value in component.

```lua
options = {
  theme = 'auto', -- lualine theme
  component_separators = { left = '', right = '' },
  section_separators = { left = '', right = '' },
  disabled_filetypes = {},     -- Filetypes to disable lualine for.
  always_divide_middle = true, -- When set to true, left sections i.e. 'a','b' and 'c'
                               -- can't take over the entire statusline even
                               -- if neither of 'x', 'y' or 'z' are present.
  globalstatus = false,        -- enable global statusline (have a single statusline
                               -- at bottom of neovim instead of one for  every window).
                               -- This feature is only available in neovim 0.7 and higher.
}
```

#### General component options

These are options that control behavior at component level
and are available for all components.

```lua
sections = {
  lualine_a = {
    {
      'mode',
      icons_enabled = true, -- Enables the display of icons alongside the component.
      -- Defines the icon to be displayed in front of the component.
      -- Can be string|table
      -- As table it must contain the icon as first entry and can use
      -- color option to custom color the icon. Example:
      -- {'branch', icon = ''} / {'branch', icon = {'', color={fg='green'}}}

      -- icon position can also be set to the right side from table. Example:
      -- {'branch', icon = {'', align='right', color={fg='green'}}}
      icon = nil,

      separator = nil,      -- Determines what separator to use for the component.
                            -- Note:
                            --  When a string is provided it's treated as component_separator.
                            --  When a table is provided it's treated as section_separator.
                            --  Passing an empty string disables the separator.
                            --
                            -- These options can be used to set colored separators
                            -- around a component.
                            --
                            -- The options need to be set as such:
                            --   separator = { left = '', right = ''}
                            --
                            -- Where left will be placed on left side of component,
                            -- and right will be placed on its right.
                            --

      cond = nil,           -- Condition function, the component is loaded when the function returns `true`.

      -- Defines a custom color for the component:
      --
      -- 'highlight_group_name' | { fg = '#rrggbb'|cterm_value(0-255)|'color_name(red)', bg= '#rrggbb', gui='style' } | function
      -- Note:
      --  '|' is synonymous with 'or', meaning a different acceptable format for that placeholder.
      -- color function has to return one of other color types ('highlight_group_name' | { fg = '#rrggbb'|cterm_value(0-255)|'color_name(red)', bg= '#rrggbb', gui='style' })
      -- color functions can be used to have different colors based on state as shown below.
      --
      -- Examples:
      --   color = { fg = '#ffaa88', bg = 'grey', gui='italic,bold' },
      --   color = { fg = 204 }   -- When fg/bg are omitted, they default to the your theme's fg/bg.
      --   color = 'WarningMsg'   -- Highlight groups can also be used.
      --   color = function(section)
      --      return { fg = vim.bo.modified and '#aa3355' or '#33aa88' }
      --   end,
      color = nil, -- The default is your theme's color for that section and mode.

      -- Specify what type a component is, if omitted, lualine will guess it for you.
      --
      -- Available types are:
      --   [format: type_name(example)], mod(branch/filename),
      --   stl(%f/%m), var(g:coc_status/bo:modifiable),
      --   lua_expr(lua expressions), vim_fun(viml function name)
      --
      -- Note:
      -- lua_expr is short for lua-expression and vim_fun is short for vim-function.
      type = nil,

      padding = 1, -- Adds padding to the left and right of components.
                   -- Padding can be specified to left or right independently, e.g.:
                   --   padding = { left = left_padding, right = right_padding }

      fmt = nil,   -- Format function, formats the component's output.
      on_click = nil, -- takes a function that is called when component is clicked with mouse.
                   -- the function receives several arguments
                   -- - number of clicks incase of multiple clicks
                   -- - mouse button used (l(left)/r(right)/m(middle)/...)
                   -- - modifiers pressed (s(shift)/c(ctrl)/a(alt)/m(meta)...)
    }
  }
}
```

#### Component specific options

These are options that are available on specific components.
For example you have option on `diagnostics` component to
specify what your diagnostic sources will be.

#### buffers component options

```lua
sections = {
  lualine_a = {
    {
      'buffers',
      show_filename_only = true,   -- Shows shortened relative path when set to false.
      hide_filename_extension = false,   -- Hide filename extension when set to true.
      show_modified_status = true, -- Shows indicator when the buffer is modified.

      mode = 0, -- 0: Shows buffer name
                -- 1: Shows buffer index
                -- 2: Shows buffer name + buffer index
                -- 3: Shows buffer number
                -- 4: Shows buffer name + buffer number

      max_length = vim.o.columns * 2 / 3, -- Maximum width of buffers component,
                                          -- it can also be a function that returns
                                          -- the value of `max_length` dynamically.
      filetype_names = {
        TelescopePrompt = 'Telescope',
        dashboard = 'Dashboard',
        packer = 'Packer',
        fzf = 'FZF',
        alpha = 'Alpha'
      }, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )

      buffers_color = {
        -- Same values as the general color option can be used here.
        active = 'lualine_{section}_normal',     -- Color for active buffer.
        inactive = 'lualine_{section}_inactive', -- Color for inactive buffer.
      },

      symbols = {
        modified = ' ●',      -- Text to show when the buffer is modified
        alternate_file = '#', -- Text to show to identify the alternate file
        directory =  '',     -- Text to show when the buffer is a directory
      },
    }
  }
}
```

#### diagnostics component options

```lua
sections = {
  lualine_a = {
    {
      'diagnostics',

      -- Table of diagnostic sources, available sources are:
      --   'nvim_lsp', 'nvim_diagnostic', 'coc', 'ale', 'vim_lsp'.
      -- or a function that returns a table as such:
      --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
      sources = { 'nvim_diagnostic', 'coc' },

      -- Displays diagnostics for the defined severity types
      sections = { 'error', 'warn', 'info', 'hint' },

      diagnostics_color = {
        -- Same values as the general color option can be used here.
        error = 'DiagnosticError', -- Changes diagnostics' error color.
        warn  = 'DiagnosticWarn',  -- Changes diagnostics' warn color.
        info  = 'DiagnosticInfo',  -- Changes diagnostics' info color.
        hint  = 'DiagnosticHint',  -- Changes diagnostics' hint color.
      },
      symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'},
      colored = true,           -- Displays diagnostics status in color if set to true.
      update_in_insert = false, -- Update diagnostics in insert mode.
      always_visible = false,   -- Show diagnostics even if there are none.
    }
  }
}
```

#### diff component options

```lua
sections = {
  lualine_a = {
    {
      'diff',
      colored = true, -- Displays a colored diff status if set to true
      diff_color = {
        -- Same color values as the general color option can be used here.
        added    = 'DiffAdd',    -- Changes the diff's added color
        modified = 'DiffChange', -- Changes the diff's modified color
        removed  = 'DiffDelete', -- Changes the diff's removed color you
      },
      symbols = {added = '+', modified = '~', removed = '-'}, -- Changes the symbols used by the diff.
      source = nil, -- A function that works as a data source for diff.
                    -- It must return a table as such:
                    --   { added = add_count, modified = modified_count, removed = removed_count }
                    -- or nil on failure. count <= 0 won't be displayed.
    }
  }
}
```

#### fileformat component options

```lua
sections = {
  lualine_a = {
    {
      'fileformat',
      symbols = {
        unix = '', -- e712
        dos = '',  -- e70f
        mac = '',  -- e711
      }
    }
  }
}
```

#### filename component options

```lua
sections = {
  lualine_a = {
    {
      'filename',
      file_status = true,      -- Displays file status (readonly status, modified status)
      path = 0,                -- 0: Just the filename
                               -- 1: Relative path
                               -- 2: Absolute path
                               -- 3: Absolute path, with tilde as the home directory

      shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                               -- for other components. (terrible name, any suggestions?)
      symbols = {
        modified = '[+]',      -- Text to show when the file is modified.
        readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
        unnamed = '[No Name]', -- Text to show for unnamed buffers.
      }
    }
  }
}
```

#### filetype component options

```lua
sections = {
  lualine_a = {
    {
      'filetype',
      colored = true,   -- Displays filetype icon in color if set to true
      icon_only = false, -- Display only an icon for filetype
      icon = { align = 'right' }, -- Display filetype icon on the right hand side
      -- icon =    {'X', align='right'}
      -- Icon string ^ in table is ignored in filetype component
    }
  }
}
```

#### tabs component options

```lua
sections = {
  lualine_a = {
    {
      'tabs',
      max_length = vim.o.columns / 3, -- Maximum width of tabs component.
                                      -- Note:
                                      -- It can also be a function that returns
                                      -- the value of `max_length` dynamically.
      mode = 0, -- 0: Shows tab_nr
                -- 1: Shows tab_name
                -- 2: Shows tab_nr + tab_name

      tabs_color = {
        -- Same values as the general color option can be used here.
        active = 'lualine_{section}_normal',     -- Color for active tab.
        inactive = 'lualine_{section}_inactive', -- Color for inactive tab.
      },
    }
  }
}
```

#### windows component options

```lua
sections = {
  lualine_a = {
    {
      'windows',
      show_filename_only = true,   -- Shows shortened relative path when set to false.
      show_modified_status = true, -- Shows indicator when the window is modified.

      mode = 0, -- 0: Shows window name
                -- 1: Shows window index
                -- 2: Shows window name + window index

      max_length = vim.o.columns * 2 / 3, -- Maximum width of windows component,
                                          -- it can also be a function that returns
                                          -- the value of `max_length` dynamically.
      filetype_names = {
        TelescopePrompt = 'Telescope',
        dashboard = 'Dashboard',
        packer = 'Packer',
        fzf = 'FZF',
        alpha = 'Alpha'
      }, -- Shows specific window name for that filetype ( { `filetype` = `window_name`, ... } )

      disabled_buftypes = { 'quickfix', 'prompt' }, -- Hide a window if its buffer's type is disabled

      windows_color = {
        -- Same values as the general color option can be used here.
        active = 'lualine_{section}_normal',     -- Color for active window.
        inactive = 'lualine_{section}_inactive', -- Color for inactive window.
      },
    }
  }
}
```

---

### Tabline

You can use lualine to display components in tabline.
The configuration for tabline sections is exactly the same as that of the statusline.

```lua
tabline = {
  lualine_a = {},
  lualine_b = {'branch'},
  lualine_c = {'filename'},
  lualine_x = {},
  lualine_y = {},
  lualine_z = {}
}
```

This will show the branch and filename components on top of neovim inside tabline.

lualine also provides 2 components, buffers and tabs, that you can use to get a more traditional tabline/bufferline.

```lua
tabline = {
  lualine_a = {'buffers'},
  lualine_b = {'branch'},
  lualine_c = {'filename'},
  lualine_x = {},
  lualine_y = {},
  lualine_z = {'tabs'}
}
```

#### Buffers

Shows currently open buffers. Like bufferline . See
[buffers options](#buffers-component-options)
for all builtin behaviors of buffers component.
You can use `:LualineBuffersJump` to jump to buffer based on index
of buffer in buffers component.

```vim
  :LualineBuffersJump 2  " Jumps to 2nd buffer in buffers component.
  :LualineBuffersJump $  " Jumps to last buffer in buffers component.
```

#### Tabs

Shows currently open tab. Like usual tabline. See
[tabs options](#tabs-component-options)
for all builtin behaviors of tabs component.
You can also use `:LualineRenameTab` to set a name for a tabpage.
For example:

```vim
:LualineRenameTab Project_K
```

It's useful when you're using rendering mode 2/3 in tabs.
To unname a tabpage run `:LualineRenameTab` without argument.

#### Tabline as statusline

You can also completely move your statusline to a tabline by configuring
`lualine.tabline` and disabling `lualine.sections` and `lualine.inactive_sections`:

```lua
tabline = {
......
  },
sections = {},
inactive_sections = {},
```

If you want a more sophisticated tabline you can use other
tabline plugins with lualine too, for example:

- [nvim-bufferline](https://github.com/akinsho/nvim-bufferline.lua)
- [tabline.nvim](https://github.com/kdheepak/tabline.nvim)

tabline.nvim even uses lualine's theme by default 🙌
You can find a bigger list [here](https://github.com/rockerBOO/awesome-neovim#tabline).

---

### Extensions

lualine extensions change statusline appearance for a window/buffer with
specified filetypes.

By default no extensions are loaded to improve performance.
You can load extensions with:

```lua
extensions = {'quickfix'}
```

#### Available extensions

- aerial
- chadtree
- fern
- fugitive
- fzf
- man
- mundo
- neo-tree
- nerdtree
- nvim-dap-ui
- nvim-tree
- quickfix
- symbols-outline
- toggleterm

#### Custom extensions

You can define your own extensions. If you believe an extension may be useful to others, then please submit a PR.

```lua
local my_extension = { sections = { lualine_a = {'mode'} }, filetypes = {'lua'} }
require('lualine').setup { extensions = { my_extension } }
```

---

### Disabling lualine

You can disable lualine for specific filetypes:

```lua
options = { disabled_filetypes = {'lua'} }
```

<!-- panvimdoc-ignore-start -->

### Contributors

Thanks to these wonderful people, we enjoy this awesome plugin.

<a href="https://github.com/nvim-lualine/lualine.nvim/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=nvim-lualine/lualine.nvim" />
</a>

<!-- panvimdoc-ignore-end -->

### Wiki

Check out the [wiki](https://github.com/nvim-lualine/lualine.nvim/wiki) for more info.

You can find some useful [configuration snippets](https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets) here. You can also share your awesome snippets with others.

If you want to extend lualine with plugins or want to know
which ones already do, [wiki/plugins](https://github.com/nvim-lualine/lualine.nvim/wiki/Plugins) is for you.

### Support

If you appreciate my work you can buy me a coffee.

<a href="https://www.buymeacoffee.com/shadmansalJ" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-black.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;"></a>
