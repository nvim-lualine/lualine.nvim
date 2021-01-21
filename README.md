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
lualine.theme = 'gruvbox'
```

All available themes are listed in [THEMES.md](./THEMES.md)

Please create a pr if you managed to port a popular theme before me, [here is how to do it](./CONTRIBUTING.md).

### Changing separator in section
Lualine defines a separator between components in given section, the default
separator is `|`. You can change the separator this way:

```lua
lualine.separator = '|'
```

or disable it

```lua
lualine.separator = ''
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
  lualine_z = {   }
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
      lualine.theme = 'gruvbox'
      lualine.separator = '|'
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
    lualine.theme = 'gruvbox'
    lualine.separator = '|'
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
