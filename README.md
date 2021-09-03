# lualine.nvim
![code size](https://img.shields.io/github/languages/code-size/hoob3rt/lualine.nvim?style=flat-square)
![license](https://img.shields.io/github/license/hoob3rt/lualine.nvim?style=flat-square)

A fast and easy to configure statusline plugin for neovim

`lualine.nvim` requires neovim 0.5

## Contributing
Feel free to create an issue/pr if you want to see anything else implemented.
If you have some question or need help with configuration start a [discussion](https://github.com/shadmansaleh/lualine.nvim/discussions).

Please read [CONTRIBUTING.md](./CONTRIBUTING.md) before opening a pr.
You can also help with documentation in [wiki](https://github.com/shadmansaleh/lualine.nvim/wiki)

## Screenshots
Here is a preview of how lualine can look like.

<p>
<img width='700' src='https://user-images.githubusercontent.com/41551030/108650373-bb025580-74bf-11eb-8682-2c09321dd18e.png'/>
<img width='700' src='https://user-images.githubusercontent.com/41551030/108650377-bd64af80-74bf-11eb-9c55-fbfc51b39fe8.png'/>
<img width='700' src='https://user-images.githubusercontent.com/41551030/108650378-be95dc80-74bf-11eb-9718-82b242ecdd54.png'/>
<img width='700' src='https://user-images.githubusercontent.com/41551030/108650381-bfc70980-74bf-11eb-9245-85c48f0f154a.png'/>
<img width='700' src='https://user-images.githubusercontent.com/41551030/103467925-32372b00-4d54-11eb-88d6-6d39c46854d8.png'/>
</p>

Screenshots of all available themes are listed in [THEMES.md](./THEMES.md)

For those who want to break the norms. You can create custom looks in lualine.

**Example** :

- [evil_lualine](examples/evil_lualine.lua)
<img width='700' src='https://user-images.githubusercontent.com/13149513/113875129-4453ba00-97d8-11eb-8f21-94a9ef565db3.png'/>

- [bubbles](examples/bubbles.lua)
<img width='700' src='https://user-images.githubusercontent.com/20235646/131350468-fc556196-5f46-4bfe-a72e-960f6a58db2c.png'/>

## Performance compared to other plugins
Unlike other statusline plugins lualine loads only defined components, nothing else.

Startup time performance measured with an amazing plugin [tweekmonster/startuptime.vim](https://github.com/tweekmonster/startuptime.vim)

All times are measured with only `startuptime.vim` and given statusline plugin installed

| clean vimrc    | lualine      | lightline    |  airline     |
| :------------: | :----------: | :----------: | :----------: |
|  8.943 ms      | 9.034 ms     |  11.463 ms   | 13.425 ms    |


## Installation
### [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'hoob3rt/lualine.nvim'
" If you want to have icons in your statusline choose one of these
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
```
### [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'hoob3rt/lualine.nvim',
  requires = {'kyazdani42/nvim-web-devicons', opt = true}
}
```

## Usage and customization

Lualine has sections as shown below.

```
+-------------------------------------------------+
| A | B | C                             X | Y | Z |
+-------------------------------------------------+
```

Each sections holds it's components e.g. current vim's mode.

<details><summary>Default config</summary>

```lua
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = {'', ''},
    section_separators = {'', ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff',
                  {'diagnostics', sources={'nvim_lsp', 'coc'}}},
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

</details>

If you want to get your current lualine config. you can
do so with 
```lua
require'lualine'.get_config()

```

---
### Starting lualine
```lua
require('lualine').setup()
```

---
### Setting a theme
```lua
options = {theme = 'gruvbox'}
```

All available themes are listed in [THEMES.md](./THEMES.md)

Please create a pr if you managed to port a popular theme before me, [here is how to do it](./CONTRIBUTING.md).

<details>
<summary>Customizing themes</summary>

```lua
local custom_gruvbox = require'lualine.themes.gruvbox'
-- Change the background of lualine_c section for normal mode
custom_gruvbox.normal.c.bg = '#112233' -- rgb colors are supported
require'lualine'.setup{
  options = { theme  = custom_gruvbox },
  ...
}
```
Theme structure is available [here](https://github.com/hoob3rt/lualine.nvim/blob/master/CONTRIBUTING.md#adding-a-theme)

</details>

---
### Separators
Lualine defines two kinds of seperators:
  * `section_separators` - separators between sections
  * `components_separators` - separators between components in sections

```lua
options = {
  section_separators = {'', ''},
  component_separators = {'', ''}
}
```

<details><summary>Disabling separators</summary>

```lua
options = {section_separators = '', component_separators = ''}
```

</details>

---
### Changing components in lualine sections

```lua
sections = {lualine_a = {'mode'}}
```

<details>
<summary><b>Available components</b></summary>

* `branch` (git branch)
* `diagnostics` (diagnostics count from your prefered source)
* `encoding` (file encoding)
* `fileformat` (file format)
* `filename`
* `filetype`
* `hostname`
* `location` (location in file in line:column format)
* `mode` (vim mode)
* `progress` (%progress in file)
* `diff` (git diff status)

</details>

#### Custom components

##### Lua functions as lualine component

```lua
local function hello()
  return [[hello world]]
end
sections = {lualine_a = {hello}}
```

##### Vim functions as lualine component

```lua
sections = {lualine_a = {'FugitiveHead'}}
```

#### Vim's statusline items as lualine component

```lua
sections = {lualine_c = {'%=', '%t%m', '%3p'}}
```

##### Vim variables as lualine component
Variables from `g:`, `v:`, `t:`, `w:`, `b:`, `o`, `go:`, `vo:`, `to:`, `wo:`, `bo:` scopes can be used.

See `:h lua-vim-variables` and `:h lua-vim-options` if you are not sure what to use.

```lua
sections = {lualine_a = {'g:coc_status', 'bo:filetype'}}
```

##### Lua expressions as lualine component
You can use any valid lua expression as a component including
  * oneliners
  * global variables
  * require statements
```lua
sections = {lualine_c = {"os.data('%a')", 'data', "require'lsp-status'.status()"}}
```
`data` is a global variable in this example.

---
### Component options
Component options can change the way a component behave.
There are two kinds of options:
  * global options affecting all components
  * local options affecting specific

Global options can be used as local options (can be applied to specific components)
but you cannot use local options as global.
Global option used locally overwrites the global, for example:
```lua
    require'lualine'.setup {
      options = {lower = true},
      sections = {lualine_a = {{'mode', lower = false}}, lualine_b = {'branch'}}
    }
```

`mode` will be displayed with `lower = false` and `branch` will be displayed with `lower = true`

#### Available options
<details>
<summary><b>Global options</b></summary>

```lua
options = {
  icons_enabled = 1, -- displays icons in alongside component
  padding = 1, -- adds padding to the left and right of components
  left_padding = 1, -- adds padding to the left of components
  right_padding =1, -- adds padding to the right of components
  upper = false, -- displays components in uppercase
  lower = false, -- displays components in lowercase
  format = nil -- format function, formats component's output
}
```

</details>

<details>
<summary><b>Local options</b></summary>

```lua
sections = {
  lualine_a = {
    {
      'mode',
      icon = nil, -- displays icon in front of the component
      separator = nil, -- Determines what separator to use for the component.
                       -- when a string is given it's treated as component_separator.
                       -- When a table is given it's treated as section_separator.
                       -- This options can be used to set colored separators
                       -- arround component. Option need to be set like `separator = {'', ''}`.
                       -- Where first element is left_separator and 2nd element is right separator.
                       -- Passing empty string disables that separator
      condition = nil, -- condition function, component is loaded when function returns true
      -- custom color for component in format
      -- color = {fg = '#rrggbb', bg= '#rrggbb', gui='style'}
      -- or highlight group
      -- color = "WarningMsg"
      color = nil,
      -- Type option specifies what type a component is.
      -- When type is omitted lualine will guess it.
      -- Available types [format: type_name(example)]
      -- mod(branch/filename), stl(%f/%m), var(g:coc_status/bo:modifiable),
      -- luae(lua expressions), vimf(viml function name)
      -- luae is short for lua-expression and vimf is short fror vim-function
      type = nil,
    }
  }
}
```

</details>

<details>
<summary><b>Component specific local options</b></summary>

#### `diagnostics` component options

```lua
sections = {
  lualine_a = {
    {
      'diagnostics',
      -- table of diagnostic sources, available sources:
      -- 'nvim_lsp', 'coc', 'ale', 'vim_lsp'
      -- Or a function that returns a table like
      --   {error=error_cnt, warning=warn_cnt, info=info_cnt, hint=hint_cnt}
      sources = {},
      -- displays diagnostics from defined severity
      sections = {'error', 'warn', 'info', 'hint'},
      -- all colors are in format #rrggbb
      color_error = nil, -- changes diagnostic's error foreground color
      color_warn = nil, -- changes diagnostic's warn foreground color
      color_info = nil, -- Changes diagnostic's info foreground color
      color_hint = nil, -- Changes diagnostic's hint foreground color
      symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'}
      update_in_insert = false, -- Update diagnostics in insert mode
    }
  }
}
```

#### `filename` component options

```lua
sections = {
  lualine_a = {
    {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
      shorting_target = 40 -- Shortens path to leave 40 space in the window
                           -- for other components. Terrible name any suggestions?
    }
  }
}
```

#### `filetype` component options

```lua
sections = {
  lualine_a = {
    {
      'filetype',
      colored = true, -- displays filetype icon in color if set to `true
      disable_text = false -- Display only icon for filetype
    }
  }
}
```

#### `diff` component options

```lua
sections = {
  lualine_a = {
    {
      'diff',
      colored = true, -- displays diff status in color if set to true
      -- all colors are in format #rrggbb
      color_added = nil, -- changes diff's added foreground color
      color_modified = nil, -- changes diff's modified foreground color
      color_removed = nil, -- changes diff's removed foreground color
      symbols = {added = '+', modified = '~', removed = '-'} -- changes diff symbols
      source = nil, -- A function that works as a data source for diff.
                    -- it must return a table like
                    {added = add_count, modified = modified_count, removed = removed_count }
                    -- Or nil on failure. Count <= 0 won't be displayed.
    }
  }
}
```

</details>

---
### Tabline
You can use lualine to display components in tabline.
The configuration for tabline sections is exactly the same as for statusline.
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
This will show branch and filename component in top of neovim inside tabline .

You can also completely move your statuline to tabline by configuring 
`lualine.tabline` and disabling `lualine.sections` and `lualine.inactive_sections`.

```lua
tabline = {
......
  },
sections = {},
inactive_sections = {},
```

If you're looking for bufferline or want to show tabs in tabline . There are
manny awesome plugins that can do that. For example:

- [nvim-bufferline](https://github.com/akinsho/nvim-bufferline.lua)
- [tabline.nvim](https://github.com/kdheepak/tabline.nvim)

tabline.nvim even uses lualines theme by default 🙌
You can find a bigger list [here](https://github.com/rockerBOO/awesome-neovim#tabline)

---
### Extensions
Lualine extensions change statusline appearance for a window/buffer with
specified filetypes.

By default no extension are loaded to improve performance. 
You can load extensions with:
```lua
extensions = {'quickfix'}
```

<details>
<summary><b>Available extensions</b></summary>

* chadtree
* fugitive
* fzf
* nerdtree
* nvim-tree
* quickfix

</details>

<details>
<summary><b>Custom extensions</b></summary>

You can define your own extensions. If you think an extension might be useful for others then please submit a pr.
```lua
local my_extension = {sections = {lualine_a = 'mode'}, filetypes = {'lua'}}
require'lualine'.setup {extensions = {my_extension}}
```

</details>

---
### Disabling lualine
You can disable lualine for specific filetypes
```lua
options = {disabled_filetypes = {'lua'}}
```
