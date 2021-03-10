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
| A | B | C                            X | Y | Z |
+-------------------------------------------------+
```

Each sections holds it's components e.g. current vim's mode.
Colorscheme of sections is mirrored, meaning section `A` will have the same colorscheme as section `Z` etc.

### Starting lualine
```lua
local lualine = require('lualine')
lualine.status()
```
### Setting a theme
```lua
lualine.options.theme = 'gruvbox'
```

All available themes are listed in [THEMES.md](./THEMES.md)

Please create a pr if you managed to port a popular theme before me, [here is how to do it](./CONTRIBUTING.md).

### Changing separator in section
Lualine defines two kinds of seperators. One is for sections and other is for components. Default section seperators are '', '' and component separators are '', ''.
They require powerline patched fonts. But you can easily change yours to something else like below

```lua
lualine.options.section_separators = {'', ''}
lualine.options.component_separators = {'', ''}
```

or disable it

```lua
lualine.options.section_separators = nil
lualine.options.component_separators = nil
```

### Changing components in lualine sections

<details>
<summary><b>Lualine defaults</b></summary>

```lua
lualine.sections = {
  lualine_a = { 'mode' },
  lualine_b = { 'branch' },
  lualine_c = { 'filename' },
  lualine_x = { 'encoding', 'fileformat', 'filetype' },
  lualine_y = { 'progress' },
  lualine_z = { 'location'  },
}

lualine.inactive_sections = {
  lualine_a = {  },
  lualine_b = {  },
  lualine_c = { 'filename' },
  lualine_x = { 'location' },
  lualine_y = {  },
  lualine_z = {  }
}
```

</details>

<details>
<summary><b>Available components</b></summary>

* branch (git branch)
* diagnostics (diagnostics count from your prefered source)
* encoding (file encoding)
* fileformat (file format)
* filename
* filetype
* location (location in file in line:column format)
* mode (vim mode)
* progress (%progress in file)
* diff (git diff status)

</details>

<details>
<summary><b>Using custom functions as lualine component</b></summary>

You can define a custom function as a lualine component

```lua
local function hello()
  return [[hello world]]
end
lualine.sections.lualine_a = { hello }
```

</details>

<details>

<summary><b>Using vim functions as lualine component</b></summary>

You can use vim functions as a lualine component

```lua
lualine.sections.lualine_b = { 'FugitiveHead' }
```

</details>

<details>
<summary><b>Using variables as lualine component</b></summary>

You can use variables from vim and lua globals as a lualine component
Variables from g:, v:, t:, w:, b:, o, go:, vo:, to:, wo:, bo: scopes
can be used. Scopes ending with o are options usualy accessed with `&` in vimscript

```lua
lualine.sections.lualine_b = { 'g:coc_status', 'bo:filetype' }
```

</details>

<details>
<summary><b>Options for components</b></summary>

### Available options:

#### Global options

Global options chnge behaviour of all suported components.
All of these options can also be specifically set to all supported components, full example below.

##### Available global options
Option   | Default | Behaviour  | Supported components
:------: | :------: | :----------: | :-----:
icons_enabled      | true     |  Displays icons on components You should have nerd-fonts supported fonts to see icons properly. | branch, fileformat, filetype, location, diagnostics
padding | 1 | Adds padding to the left and right of components | all
left_padding | 1 | Adds padding to the left of components | all
right_padding | 1 | Adds padding to the right of components | all
upper | false | Changes components to be uppercase | all
lower | false | Changes components to be lowercase | all
format | nil | Takes a function . The funtion gets the result of component as argument and it's return value is displayed. So this function can parse and format the output as user wants. | all
##### Global options example
```lua
lualine.options.icons_enabled = true
```

#### Component specific options
As mentioned above, all global options can be applied to specific components.
However there are some options which are component-only (you cannot set them as globals)
Option   | Default | Behaviour
:------: | :------: | :----:
icon | Differs for each component | Displays an icon in front of the component
color | nil | Sets custom color for the component in this format<br></br>`color = {fg = '#rrggbb', bg= '#rrggbb', gui='style'}`<br></br>The fields of color table are optional and default to theme

In addition, some components have unique options.

* `diagnostics` component options

Option   | Default | Behaviour | Format
:------: | :------: | :----: | :---:
sources | `nil` | displays diagnostic count from defined source | array containing one or many string from set `{'nvim_lsp', 'coc', 'ale'}`
sections | `{'error', 'warn', 'info'}` | displays diagnostics of defined severity | array containing one or many string from set `{'error', 'warn', 'info'}`
color_error | `DiffDelete` foreground color | changes diagnostic's error section foreground color | color in `#rrggbb` format
color_warn | `DiffText` foreground color | changes diagnostic's warn section foreground color | color in `#rrggbb` format
color_info | `Normal` foreground color | changes diagnostic's info section foreground color | color in `#rrggbb` format
symbols | `{error = ' ', warn = ' ', info = ' '}` or `{error = 'E:', warn = 'W:', info = 'I:'}` | changes diagnostic's info section foreground color | table containing one or more symbols for levels |

* `filename` component options

Option   | Default | Behaviour
:------: | :------: | :----:
file_status | true | Displays file status (readonly status, modified status)
full_path | false | Displays relative path if set to `true`, absolute path if set to `false`
shorten | true | if `full_path` is true and `shorten` is `false` it shortens absolute path `aaa/bbb/ccc/file` to `a/b/c/file`

* `diff` component options

Option   | Default | Behaviour | Format
:------: | :------: | :----: | :---:
colored | true | displays diff status in color if set to `true` |
color_added | `DiffAdd` foreground color | changes diff's added section foreground color | color in `#rrggbb` format
color_modified | `DiffChange` foreground color | changes diff's changed section foreground color | color in `#rrggbb` format
color_removed | `DiffDelete` foreground color | changes diff's removed section foreground color | color in `#rrggbb` format
symbols | `{added = '+', modified = '~', removed = '-'}` | changes diff's symbols | table containing on or more symbols |


##### Component options example
```lua
lualine.sections.lualine_b = {
  {
    'branch',
    icon = '',
    upper = true,
    color = { fg = '#00aa22' }
  },
  {
    'filename',
    full_name = true,
    shorten = true,
    format = function(name)
      -- Capitalize first charecter of filename to capital.
      local path, fname = name:match('(.*/)(.*)')
        if not path then path = ''; fname = name end
        return path .. fname:sub(1, 1):upper() .. fname:sub(2, #fname)
    end
  }
}
```

</details>

<details>
<summary><b>Using tabline as statusline (statusline on top)</b></summary>
You can use lualine to display components in tabline.
The sections, configurations and highlights are same as statusline.

```
lualine.tabline = {
  lualine_a = { },
  lualine_b = { 'branch' },
  lualine_c = { 'filename' },
  lualine_x = { },
  lualine_y = { },
  lualine_z = { },
}
```
This will show branch and filename component in top of neovim inside tabline .


You can also completely move your statuline to tabline by configuring lualine.tabline
instead of lualine.sections & lualine.inactive_sections and setting them to empty
```
lualine.tabline = {
......
  }
lualine.sections = {}
lualine.inactive_sections = {}
```
</detils>

### Loading plugin extensions
Lualine extensions change statusline appearance for a window/buffer with a plugin loaded e.g. [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim)

By default no plugin extension are loaded to improve performance. If you are using a plugin which is supported you can load it this way:
```lua
lualine.extensions = { 'fzf' }
```

All available extensions are listed in [EXTENSIONS.md](./EXTENSIONS.md)

### Lua config example

<details>
<summary><b>packer config</b></summary>

```lua
  use {
    'hoob3rt/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
    config = function()
      require('lualine').status{
        options = {
          theme = 'gruvbox',
          section_separators = {'', ''},
          component_separators = {'', ''},
          icons_enabled = true,
        },
        sections = {
          lualine_a = { {'mode', upper = true} },
          lualine_b = { {'branch', icon = ''} },
          lualine_c = { {'filename', file_status = true} },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location'  },
        },
        inactive_sections = {
          lualine_a = {  },
          lualine_b = {  },
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {  },
          lualine_z = {   }
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
lua require("lualine").status()
```
</details>
