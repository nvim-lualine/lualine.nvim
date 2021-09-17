This file contains braking changes that have been made in this branch to
make it easier to switch from [hoob3rt/lualine.nvim](https://github.com/hoob3rt/lualine.nvim)
In this file contains changes in timed order . It's possible breaking change
has been made to several times to same thing . In that case the one in the
bottom indicates current state.

### Color option unification
color_added, color_modified, color_removed options in diff & color_error,
color_warning, color_info, color_hint too only fg color that was different
from other color options that took fg ,bg & gui changes were made to make
them similar.

So instead of
```lua
color_added = '#rrbbgg',
```
You'll have
```lua
color_added = { fg = '#rrbbgg' }
```
for same effect.

### Theme rename
So themes were renamed so they are same as their `g:color_name`
- oceanicnext      -> OceanicNext
- papercolor       -> PaperColor
- tomorrow         -> Tomorrow
- gruvbox_material -> gruvbox-material
- modus_vivendi    -> modus-vivendi

### function components now receive some default parameters
Now function components receive same args as `update_status`. So fuctions
signature is now
```lua
function(self, is_active)
```
`self` is a table that represents the component in lualine & `is_active` is
a boolean value that indicates whether the function is being evaluated
for active statusline or inactive statusline. This means function components
can be more versatile. But also means you can't use functions that take
optional arguments directly as function component . `lsp_status` is such
a cases it takes an optional `winid` in first argument .
You can wrap it with a function so those self & is_active doesn't
get passed to `lsp_status`
```lua
lualine_c = { function() return require'lsp-status'.status() end}
```

### Options simplification
See [#24](https://github.com/shadmansaleh/lualine.nvim/pull/24) for details
- `upper` & `lower` removed use `string.upper/lower` in `fmt` option.
- separators are specified by left & right instead of position
  instead of `{'>', '<'}` you'll use `{left= '>', right='<'}`.
- `left_padding` & `right_padding` removed. You can specify left or right
  padding with padding option like padding = `{ left = 5 }`
- Option rename:
 - condition -> cond
 - format -> fmt
 - disable_text -> icon_only
- color_added, color_modified, color_removed are now available as added,
modified, removed in diff_color table option
- color_error, color_warning, color_info, color_hint are now available
as error, warning, info, hint in diagnostics_color table option
