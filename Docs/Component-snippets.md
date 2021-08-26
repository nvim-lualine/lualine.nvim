Here we list various snippets for components that can be useful
for users. Most of these are functions that can be used as regular
function component in any section of lualine. If you have some
nice component snippets that you want to share. You can add proposal
to get them added here.

### Trailing whitespaces
Shows 'TW' in lualine when there are trailing white space in current
buffer.
```lua
function()
  return vim.fn.search([[\s\+$]], 'nw') ~= 0 and 'TW' or ''
end
```

### Mixed indent
Shows 'MI' in lualine when both tab and spaces are used for indenting
current buffer.
```lua
function()
  local space_indent = vim.fn.search([[\v^ +]], 'nw') > 0
  local tab_indent = vim.fn.search([[\v^\t+]], 'nw') > 0
  local mixed = (space_indent and tab_indent)
                 or vim.fn.search([[\v^(\t+ | +\t)]], 'nw') > 0
  return mixed and 'MI' or ''
end
```

### Using external source for branch
If you have other plugins installed that keep track of
branch info . lualine can reuse that info.
- ***vim-fugitive***

```lua
  lualine_b = { {'FugitiveHead', icon = ''}, },
```

- ***gitsigns.nvim***

```lua
    lualine_b = { {'b:gitsigns_head', icon = ''}, },
```

### Using external source for diff
If you have other plugins installed that keep track of
info. lualine can reuse that info. And you don't need
to have two separate plugins doing the same thing.

- ***gitsigns.nvim***

```lua
local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed
    }
  end
end

require'lualine'.setup {
  sections = {
    lualine_b = { {'diff', source = diff_source}, },
  }
}
```
