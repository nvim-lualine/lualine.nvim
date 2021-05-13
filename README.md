# lualine.nvim
![code size](https://img.shields.io/github/languages/code-size/hoob3rt/lualine.nvim?style=flat-square)
![license](https://img.shields.io/github/license/hoob3rt/lualine.nvim?style=flat-square)

A blazing fast and easy to configure neovim statusline written in pure lua.

`lualine.nvim` requires neovim 0.5

## Contributing
Please read [CONTRIBUTING.md](./CONTRIBUTING.md) before contributing.

You can check [this](https://github.com/hoob3rt/lualine.nvim/projects/3) out if you want to see what is currently being worked on.

Feel free to create an issue/pr if you want to see anything else implemented.

## Screenshots
Here is a preview of how lualine can look like.

![normal_cropped](https://user-images.githubusercontent.com/41551030/108650373-bb025580-74bf-11eb-8682-2c09321dd18e.png)
![powerline_cropped](https://user-images.githubusercontent.com/41551030/108650377-bd64af80-74bf-11eb-9c55-fbfc51b39fe8.png)
![diff_croped](https://user-images.githubusercontent.com/41551030/108650378-be95dc80-74bf-11eb-9718-82b242ecdd54.png)
![diagnostics_cropped](https://user-images.githubusercontent.com/41551030/108650381-bfc70980-74bf-11eb-9245-85c48f0f154a.png)
![replace](https://user-images.githubusercontent.com/41551030/103467925-32372b00-4d54-11eb-88d6-6d39c46854d8.png)

Screenshots of all available themes are listed in [THEMES.md](./THEMES.md)

For those who want to break the norms. You can create custom looks in lualine .

**Example** :

- [evil_lualine](https://gist.github.com/shadmansaleh/cd526bc166237a5cbd51429cc1f6291b)
![evil_lualine_image](https://user-images.githubusercontent.com/13149513/113875129-4453ba00-97d8-11eb-8f21-94a9ef565db3.png)

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
Lualine can be configured with both lua and vimscript.
Click [here](#lua-config-example) if you want to see a config example in lua and [here](#vimscript-config-example) if you want to see a config example in vimscript.

Lualine has sections as shown below.

```
+-------------------------------------------------+
| A | B | C                             X | Y | Z |
+-------------------------------------------------+
```

Each sections holds it's components e.g. current vim's mode.
Colorscheme of sections is mirrored, meaning section `A` will have the same colorscheme as section `Z` etc.

---
### Starting lualine
```lua
require('lualine').setup()
```

<details><summary>Default config</summary>

```lua
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    component_separators = {'', ''},
    section_separators = {'', ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
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
-- Chnage the background of lualine_c section for normal mode
custom_gruvbox.normal.c.bg = '#112233' -- rgb colors are supported
require'lualine'.setup{
  options = { theme  = custom_gruvbox },
  ...
}
```
You can checkout structure of a lualine theme [here](https://github.com/hoob3rt/lualine.nvim/blob/master/CONTRIBUTING.md#adding-a-theme)

</details>

---
### Changing separators
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
sections = {lualine_c = {"os.data('%a')", 'data', require'lsp-status'.status}}
```
`data` is a global variable in this example.

---
### Component options
Component options can change the way a component behave.
There are two kinds of options:
    *   global options affecting all components
    *   local options affecting specific

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

<details>
<summary><b>Global options</b></summary>

Option   | Default | Behaviour | Format
:------: | :------: | :----: | :---:
icons_enabled      | true     |  Displays icons on components You should have nerd-fonts supported fonts to see icons properly. | branch, fileformat, filetype, location, diagnostics
padding | 1 | Adds padding to the left and right of components | All
left_padding | 1 | Adds padding to the left of components | All
right_padding | 1 | Adds padding to the right of components | All
separator | (component_separators) | which separator to use at end of component | all
upper | false | Changes components to be uppercase | All
lower | false | Changes components to be lowercase | All
format | nil | Takes a function . The funtion gets the result of component as argument and it's return value is displayed. So this function can parse and format the output as user wants. | All

</details>

<details>
<summary><b>Local options</b></summary>

Option   | Default | Behaviour | Supported components
:------: | :------: | :------: | :--------:
icon | Differs for each component | Displays an icon in front of the component | All
condition | nil | Takes a function. The component is loaded if the function returns true otherwise not. It can be used to load some comoonents on specific cases. | All
color | nil | Sets custom color for the component in this format<br></br>`color = {fg = '#rrggbb', bg= '#rrggbb', gui='style'}`<br></br>The fields of color table are optional and default to theme <br></br>Color option can also be a string containing highlight group name `color = "WarningMsg"`. One neat trick set the color to highlight group name then change that highlight with :hi command to change color of that component at runtime. | All

</details>

<details>
<summary><b>Component specific local options</b></summary>

#### `diagnostics` component options

Option   | Default | Behaviour | Format
:------: | :------: | :----: | :---:
sources | `nil` | displays diagnostic count from defined source | array containing one or many string from set `{'nvim_lsp', 'coc', 'ale', 'vim_lsp'}`
sections | `{'error', 'warn', 'info'}` | displays diagnostics of defined severity | array containing one or many string from set `{'error', 'warn', 'info'}`
color_error | `DiffDelete` foreground color | changes diagnostic's error section foreground color | color in `#rrggbb` format
color_warn | `DiffText` foreground color | changes diagnostic's warn section foreground color | color in `#rrggbb` format
color_info | `Normal` foreground color | changes diagnostic's info section foreground color | color in `#rrggbb` format
symbols | `{error = ' ', warn = ' ', info = ' '}` or `{error = 'E:', warn = 'W:', info = 'I:'}` | changes diagnostic's info section foreground color | table containing one or more symbols for levels |

#### `filename` component options

Option   | Default | Behaviour
:------: | :------: | :----:
file_status | true | Displays file status (readonly status, modified status)
path | 0 | filename `path` option: 0 = just filename, 1 = relative path, 2 = absolute path
symbols | `{modified = '[+]', readonly = '[-]'}` | changes status symbols | table containing one or more symbols |

#### `filetype` component options

Option   | Default | Behaviour
:------: | :------: | :----:
colored | true | Displays filetype icon in color if set to `true`

#### `diff` component options

Option   | Default | Behaviour | Format
:------: | :------: | :----: | :---:
colored | true | displays diff status in color if set to `true` |
color_added | `DiffAdd` foreground color | changes diff's added section foreground color | color in `#rrggbb` format
color_modified | `DiffChange` foreground color | changes diff's changed section foreground color | color in `#rrggbb` format
color_removed | `DiffDelete` foreground color | changes diff's removed section foreground color | color in `#rrggbb` format
symbols | `{added = '+', modified = '~', removed = '-'}` | changes diff's symbols | table containing one or more symbols |


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

---
### Disabling lualine
You can disable lualine for specific filetypes
```lua
options = {disabled_filetypes = {'lua'}}
```

---
### Lua config example

<details>
<summary><b>packer config</b></summary>

```lua
  use {
    'hoob3rt/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
    config = function()
      require('lualine').setup{
        options = {
          theme = 'gruvbox',
          section_separators = {'', ''},
          component_separators = {'', ''},
          disabled_filetypes = {},
          icons_enabled = true,
        },
        sections = {
          lualine_a = { {'mode', upper = true} },
          lualine_b = { {'branch', icon = ''} },
          lualine_c = { {'filename', file_status = true} },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {  },
          lualine_b = {  },
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {  },
          lualine_z = {  }
        },
        extensions = { 'fzf' }
      }
    end
  }
```

</details>

### Vimscript config example

<details>
<summary><b>vimrc config</b></summary>

```vim
let g:lualine = {
    \'options' : {
    \  'theme' : 'gruvbox',
    \  'section_separators' : ['', ''],
    \  'component_separators' : ['', ''],
    \  'disabled_filetypes' : [],
    \  'icons_enabled' : v:true,
    \},
    \'sections' : {
    \  'lualine_a' : [ ['mode', {'upper': v:true,},], ],
    \  'lualine_b' : [ ['branch', {'icon': '',}, ], ],
    \  'lualine_c' : [ ['filename', {'file_status': v:true,},], ],
    \  'lualine_x' : [ 'encoding', 'fileformat', 'filetype' ],
    \  'lualine_y' : [ 'progress' ],
    \  'lualine_z' : [ 'location'  ],
    \},
    \'inactive_sections' : {
    \  'lualine_a' : [  ],
    \  'lualine_b' : [  ],
    \  'lualine_c' : [ 'filename' ],
    \  'lualine_x' : [ 'location' ],
    \  'lualine_y' : [  ],
    \  'lualine_z' : [  ],
    \},
    \'extensions' : [ 'fzf' ],
    \}
lua require("lualine").setup()
```
</details>
