This file contains breaking changes that have been made in this branch to
make it easier to switch from [hoob3rt/lualine.nvim](https://github.com/hoob3rt/lualine.nvim)
This file contains changes in chronological order. It's possible breaking change
has been made several times to the same thing. In that case the one nearest the
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
for the same effect.

### Theme rename
Some themes were renamed so they are same as their `g:color_name`
- oceanicnext      -> OceanicNext
- papercolor       -> PaperColor
- tomorrow         -> Tomorrow
- gruvbox_material -> gruvbox-material
- modus_vivendi    -> modus-vivendi

### function components now receive some default parameters
Now function components receive the same args as `update_status`. So the function
signature is now:
```lua
function(self, is_active)
```
`self` is a table that represents the component in lualine & `is_active` is
a boolean value that indicates whether the function is being evaluated
for an active statusline or an inactive statusline. This means function components
can be more versatile. But it also means you can't use functions that take
optional arguments directly as function component. `lsp_status` is such
a case that takes an optional `winid` in its first argument.
You can wrap it with a function so the `self` & `is_active` don't
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
  padding with a padding option like padding = `{ left = 5 }`
- Option rename:
 - condition -> cond
 - format -> fmt
 - disable_text -> icon_only
- color_added, color_modified, color_removed are now available as added,
modified, removed in diff_color table option
- color_error, color_warning, color_info, color_hint are now available
as error, warn, info, hint in diagnostics_color table option
