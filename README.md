# lualine.nvim
![code size](https://img.shields.io/github/languages/code-size/hoob3rt/lualine.nvim?style=flat-square)
![license](https://img.shields.io/github/license/hoob3rt/lualine.nvim?style=flat-square)

![last commit](https://img.shields.io/github/last-commit/hoob3rt/lualine.nvim?style=flat-square)
![contributions](https://img.shields.io/github/contributors/hoob3rt/lualine.nvim?style=flat-square)
![issues](https://img.shields.io/github/issues-raw/hoob3rt/lualine.nvim?style=flat-square)
![prs](https://img.shields.io/github/issues-pr-raw/hoob3rt/lualine.nvim?style=flat-square)

A blazing fast and easy to configure neovim statusline written in pure lua.

`lualine.nvim` requires neovim 0.5

## Contributing
Please read [CONTRIBUTING.md](./CONTRIBUTING.md) before contributing.

You can check [this](https://github.com/hoob3rt/lualine.nvim/projects/3) out if you want to see what is currently being worked on.

Feel free to create an issue/pr if you want to see anything else implemented.

## Screenshots
Here is a preview of how lualine can look like.

![normal](https://user-images.githubusercontent.com/41551030/103467902-06b44080-4d54-11eb-89db-6d3bebf449fa.png)
![insert](https://user-images.githubusercontent.com/41551030/103467914-1764b680-4d54-11eb-9e3d-528d3568dce7.png)
![visual](https://user-images.githubusercontent.com/41551030/103467916-23507880-4d54-11eb-804e-5b1c4d6e3db3.png)
![command](https://user-images.githubusercontent.com/41551030/103467919-2ba8b380-4d54-11eb-8585-6c667fd5082e.png)
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
Lualine has sections as shown below.

```
+-------------------------------------------------+
| A | B | C                            X | Y | Z |
+-------------------------------------------------+
```

Each sections holds it's components e.g. current vim's mode.
Colorscheme of sections is mirrored, meaning section `A` will have the same colorscheme as section `Z` etc.

Configuration is currently limited to lua, please use lua block or a separate lua file to configure lualine.

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
lualine.section_separators = {'', ''}
lualine.component_separators = {'', ''}
```

or disable it

```lua
lualine.section_separators = {'', ''}
lualine.component_separators = {'', ''}
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

* general
  * branch
  * encoding
  * fileformat
  * filename
  * filetype
  * location
  * mode
  * progress
* plugin
  * signify

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

```
lualine.sections.lualine_b = { 'FugitiveHead' }
```

</details>

<details>
<summary><b>Using variables as lualine component</b></summary>

You can use variables from vim and lua globals as a lualine component
Variables from g:, v:, t:, w:, b:, o, go:, vo:, to:, wo:, bo: scopes
can be used. Scopes ending with o are options usualy accessed with `&` in vimscript

```
lualine.sections.lualine_b = { 'g:coc_status', 'bo:filetype' }
```

</details>

<details>
<summary><b>Options for components</b></summary>

### Available options:

#### Global Default options

Default options act as default for all components
- icons_enabled (Default: true)
  Displays icons on components
  You should have powerline supported fonts to see
  icons properly.\
  *Suported by branch, fileformat, filetype, location*\
  Example:
  ```lua
  lualine.options.icons_enabled = true

  ```

#### Genaral options
  These options are available for all components.\
    option&nbsp; &nbsp; &nbsp;(default_value)\
    ----------&nbsp; &nbsp; &nbsp; &nbsp;----------------------
- padding       (1)\
  spaces on left and right
- left_padding  (1)\
  spaces on left
- right_padding (1)\
  spaces on right
- icon          (depends on component)
  displays an icon infront of component
- icons_enabled (true)
  whether to show icon(if available)
- separator ('|')
  which separator to use at end of component
- upper         (false)\
  Displayed in upper case
- lower         (false)\
  Displayed in lower case
- format        (nil)\
  Takes a function . The funtion gets the result of component
  as argument and it's return value is displayed. So this function
  can parse and format the output as user wants.
- color         (Theme colors)\
  color option can be used to set custom color to a component\
  **Color format:**\
  `lua color = {fg = '#rrggbb', bg= '#rrggbb', gui='style'}`\
  the members of color table are optional and default to theme

#### Component specific options
  These options are available for specific components only.\
  List of options are given below.
- filename
  - file_status        (true)\
   Whether to display filemodified status in filename
  - shorten      (true)\
   Whether to display full/relative path with filename
  - full_path     (false)\
   Whether to display full path when shorten is false
- fileformat
  - icons_enabled (true)\
   Whether to displays icon before component
- signify
  - colored        (true)\
    Whether to show colors. Colors are automaticaly
		extracted from colorscheme . If you want to change
		any of those you can use options given below.
  - color_added    ('#90ee90')\
    Foreground color of added section
  - color_modified ('#f0e130')\
    Foreground color of modified section
  - color_removed  ('#ff0038')\
    Foreground color of removed section

**Example:**
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

### Loading plugin extensions
Lualine extensions change statusline appearance for a window/buffer with a plugin loaded e.g. [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim)

By default no plugin extension are loaded to improve performance. If you are using a plugin which is supported you can load it this way:
```lua
lualine.extensions = { 'fzf' }
```

All available extensions are listed in [EXTENSIONS.md](./EXTENSIONS.md)

### Full config example using [packer.nvim](https://github.com/wbthomason/packer.nvim)

<details>
<summary><b>packer config</b></summary>

```lua
  use {
    'hoob3rt/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
    config = function()
      local lualine = require('lualine')
      lualine.options = {
        theme = 'gruvbox',
        section_separators = {'', ''},
        component_separators = {'', ''},
        icons_enabled = true,
      }
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
        lualine_z = {   }
      }
      lualine.extensions = { 'fzf' }
      lualine.status()
    end
  }
```

</details>

### Full config example inside `.vimrc`/`init.vim`

<details>
<summary><b>vimrc config</b></summary>

```vim
lua << EOF
local lualine = require('lualine')
    lualine.options = {
      theme = 'gruvbox',
      section_separators = {'', ''},
      component_separators = {'', ''},
      icons_enabled = true,
    }
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
      lualine_z = {   }
    }
    lualine.extensions = { 'fzf' }
    lualine.status()
EOF
```
</details>
