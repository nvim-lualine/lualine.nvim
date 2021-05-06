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

### Starting lualine
All configurations happens in the setup function
```lua
require('lualine').setup{}
```
### Setting a theme
```lua
options = {theme = 'gruvbox'}
```

All available themes are listed in [THEMES.md](./THEMES.md)

Please create a pr if you managed to port a popular theme before me, [here is how to do it](./CONTRIBUTING.md).

<details>
<summary>Tweeking themes</summary>

You like a theme but would like to tweek some colors.
You can do that in your config easily.

Example:
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

### Changing separators
Lualine defines two kinds of seperators. One is for sections and other is for components. Default section seperators are '', '' and component separators are '', ''.
They require powerline patched fonts. But you can easily change yours to something else like below

```lua
options = {
  section_separators = {'', ''},
  component_separators = {'', ''}
}
```

or disable it

```lua
options = {section_separators = '', component_separators = ''}
```

### Changing components in lualine sections

<details>
<summary><b>Lualine defaults</b></summary>

```lua
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
* hostname
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
sections = {lualine_a = {hello}}
```

</details>

<details>

<summary><b>Using vim functions as lualine component</b></summary>

You can use vim functions as a lualine component

```lua
sections = {lualine_a = {'FugitiveHead'}}
```

</details>

<details>
<summary><b>Using variables as lualine component</b></summary>

You can use variables from vim a lualine component
Variables from g:, v:, t:, w:, b:, o, go:, vo:, to:, wo:, bo: scopes
can be used. Scopes ending with o are options usualy accessed with `&` in vimscript

```lua
sections = {lualine_a = {'g:coc_status', 'bo:filetype'}}
```

</details>

<details>
<summary><b>Using lua expressions as lualine component</b></summary>

You can use any valid lua expression as a component . This allows global
variables to be used as  a component too. Even require statements can be used to access values returned by specific scripts.
One liner functions can be inlined by utilizeing this .

For exmaple this will show day of the week.
And 2nd one will display current value of global variabke data.

```lua
sections = {lualine_c = {"os.data('%a')", 'data'}}
```

</details>

<details>
<summary><b>Options for components</b></summary>

### Available options:

Options can change the way a component behave.
There are two kinds of options some that work on every kind of component.
Even the ones you create like custom function component . And some that only
work on specific component.
Detailed list of available options are given below.

#### Global options
These options are available for all components.

Option   | Default | Behaviour | Supported components
:------: | :------: | :------: | :--------:
icons_enabled      | true     |  Displays icons on components You should have nerd-fonts supported fonts to see icons properly. | branch, fileformat, filetype, location, diagnostics
icon | Differs for each component | Displays an icon in front of the component | All
padding | 1 | Adds padding to the left and right of components | All
left_padding | 1 | Adds padding to the left of components | All
right_padding | 1 | Adds padding to the right of components | All
separator | (component_separators) | which separator to use at end of component | all
upper | false | Changes components to be uppercase | All
lower | false | Changes components to be lowercase | All
format | nil | Takes a function . The funtion gets the result of component as argument and it's return value is displayed. So this function can parse and format the output as user wants. | All
condition | nil | Takes a function. The component is loaded if the function returns true otherwise not. It can be used to load some comoonents on specific cases. | All
color | nil | Sets custom color for the component in this format<br></br>`color = {fg = '#rrggbb', bg= '#rrggbb', gui='style'}`<br></br>The fields of color table are optional and default to theme <br></br>Color option can also be a string containing highlight group name `color = "WarningMsg"`. One neat trick set the color to highlight group name then change that highlight with :hi command to change color of that component at runtime. | All
disabled_filetypes | {} | Disables lualine for specific filetypes | It works on entire statusline instead of on a single component

#### Using global options
Global options can be set in two ways. One is as part of options table in setup.

```lua
require'lualine'.setup{
  options = {
    icons_enabled = true,
    padding = 2,
  }
}
```
When set this way these values work as default for all component.
These defaults can be overwritten by setting option as part of component
configuration like following.

```lua
lualine_a = {
  -- Displays only first char of mode name
  {'mode', format=function(mode_name) return mode_name:sub(1,1) end},
  -- Disables icon for branch component
  {'branch', icons_enabled=false},
},
lualine_c = {
  -- Displays filename only when window is wider then 80
  {'filename', condition=function() return vim.fn.winwidth(0) > 80 end},
}
```

#### Component specific options
In addition, some components have unique options.

* `diagnostics` component options

Option   | Default | Behaviour | Format
:------: | :------: | :----: | :---:
sources | `nil` | displays diagnostic count from defined source | array containing one or many string from set `{'nvim_lsp', 'coc', 'ale', 'vim_lsp'}`
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
symbols | `{modified = '[+]', readonly = '[-]'}` | changes status symbols | table containing one or more symbols |

* `diff` component options

Option   | Default | Behaviour | Format
:------: | :------: | :----: | :---:
colored | true | displays diff status in color if set to `true` |
color_added | `DiffAdd` foreground color | changes diff's added section foreground color | color in `#rrggbb` format
color_modified | `DiffChange` foreground color | changes diff's changed section foreground color | color in `#rrggbb` format
color_removed | `DiffDelete` foreground color | changes diff's removed section foreground color | color in `#rrggbb` format
symbols | `{added = '+', modified = '~', removed = '-'}` | changes diff's symbols | table containing one or more symbols |


Component specific options can only be set with component configs.

##### Component options example
```lua
sections = {
  lualine_b = {
    {'branch', icon = '', upper = true, color = {fg = '#00aa22'}}, {
      'filename',
      full_name = true,
      shorten = true,
      format = function(name)
        -- Capitalize first charecter of filename to capital.
        local path, fname = name:match('(.*/)(.*)')
        if not path then
          path = '';
          fname = name
        end
        return path .. fname:sub(1, 1):upper() .. fname:sub(2, #fname)
      end
    }
  }
}
```

</details>

<details>
<summary><b>Using tabline as statusline (statusline on top)</b></summary>
You can use lualine to display components in tabline.
The sections, configurations and highlights are same as statusline.

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


You can also completely move your statuline to tabline by configuring lualine.tabline
instead of lualine.sections & lualine.inactive_sections and setting them to empty
```lua
tabline = {
......
  },
sections = {},
inactive_sections = {},
```
</details>

### Loading plugin extensions
Lualine extensions change statusline appearance for a window/buffer with a plugin loaded e.g. [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim)

By default no plugin extension are loaded to improve performance. If you are using a plugin which is supported you can load it this way:
```lua
extensions = { 'fzf' }
```

<details>
<summary><b>Available extensions</b></summary>

* fugitive
* fzf
* nerdtree
* chadtree
* nvim-tree

</details>

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
