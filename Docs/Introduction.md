### What's lualine

lualine is a statusline plugin written for neovim . It's primarily written in
lua . It's goal is to provide a easy to customize and fast statusline.
The idea is we will try our best to provide sane defaults also a way to
overwrite that default . Best kind of customize is the one where you have
the power to customize but not the need .

### Requirements

- [neovim](https://github.com/neovim/neovim) >= 0.5
- [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) | Only
  if you want filetype icons.

### Why use lualine

There are lots of great statusline plugins . There's [lightline](https://github.com/itchyny/lightline.vim),
[airline](https://github.com/vim-airline/vim-airline),
[galaxyline](https://github.com/glepnir/galaxyline.nvim),
[feline.nvim](https://github.com/famiu/feline.nvim),
[windline](https://github.com/windwp/windline.nvim) and bunch [others](https://github.com/rockerBOO/awesome-neovim#statusline).

I think among these lualine is comparable to lightline and airline. As
it provides more out of the box feeling then lightline while being more
configurable too. I'm probably not the right person to comment on airline as
I've used it for really short period. But the reason I couldn't use it was
because it was just not configurable and I believe others will agree it slow.
Those aren't an issue with lualine.

galaxyline & feline.nvim provides more control over statusline. They can be used
as a library to build your custom statusline. As 
[evil_lualine](https://github.com/shadmansaleh/lualine.nvim/blob/master/examples/evil_lualine.lua)
shows lualine can be used like that too at least to some extent.
But still if you want that I'd definitely recommend taking a look at them.
The down side of building statusline that way is you need to specify everything.
That makes building even simple statusline harder.

Speciality of windline is it provides animations. Whether you like animations
or not do take a look at that it's
definitely cool :D

In the end I'll just say try out lualine and see if you like it or not.
If you like it that's your reason for use]ing it right there. If you don't
you can go ahead and explore the other options, enjoy.


### Instalation:

Grab your favorite plugin manager and add lualine in your plugin list.

- *** Packer ***
```lua
use { 'shadmansaleh/lualine.nvim',
  requires = {'kyazdani42/nvim-web-devicons', opt = true}
}
```
- *** VimPlug ***
```vim
Plug 'shadmansaleh/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
```

- *** paq.nvim ***
```lua
require'paq' {
  'shadmansaleh/lualine.nvim',
  'kyazdani42/nvim-web-devicons'
}

- *** Dein.vim
```vim
call dein#add('shadmansaleh/lualine.nvim')
call dein#add('kyazdani42/nvim-web-devicons')
```
