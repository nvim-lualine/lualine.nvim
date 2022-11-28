local Tab = require('lualine.utils.class'):extend()

local modules = require('lualine_require').lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
}

---initialize a new tab from opts
---@param opts table
function Tab:init(opts)
  assert(opts.tabnr, 'Cannot create Tab without tabnr')
  self.tabnr = opts.tabnr
  self.tabId = opts.tabId
  self.options = opts.options
  self.highlights = opts.highlights
end

---returns name for tab. Tabs name is the name of buffer in last active window
--- of the tab.
---@return string
function Tab:label()
  local ok, custom_tabname = pcall(vim.api.nvim_tabpage_get_var, self.tabId, 'tabname')
  if not ok then
    custom_tabname = nil
  end
  if custom_tabname and custom_tabname ~= '' then
    return modules.utils.stl_escape(custom_tabname)
  end
  local buflist = vim.fn.tabpagebuflist(self.tabnr)
  local winnr = vim.fn.tabpagewinnr(self.tabnr)
  local bufnr = buflist[winnr]
  local file = modules.utils.stl_escape(vim.api.nvim_buf_get_name(bufnr))
  local buftype = vim.fn.getbufvar(bufnr, '&buftype')
  if vim.api.nvim_buf_get_option(bufnr, 'filetype') == 'fugitive' then
    return 'fugitive: ' .. vim.fn.fnamemodify(file, ':h:h:t')
  elseif buftype == 'help' then
    return 'help:' .. vim.fn.fnamemodify(file, ':t:r')
  elseif buftype == 'terminal' then
    local match = string.match(vim.split(file, ' ')[1], 'term:.*:(%a+)')
    return match ~= nil and match or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif vim.fn.isdirectory(file) == 1 then
    return vim.fn.fnamemodify(file, ':p:.')
  elseif file == '' then
    return '[No Name]'
  end
  return vim.fn.fnamemodify(file, ':t')
end

---returns rendered tab
---@return string
function Tab:render()
  local name = self:label()
  if self.options.fmt then
    name = self.options.fmt(name or '')
  end
  if self.ellipse then -- show ellipsis
    name = '...'
  else
    -- different formats for different modes
    if self.options.mode == 0 then
      name = tostring(self.tabnr)
    elseif self.options.mode == 1 then
      name = name
    else
      name = string.format('%s %s', tostring(self.tabnr), name)
    end
  end
  name = Tab.apply_padding(name, self.options.padding)
  self.len = vim.fn.strchars(name)

  -- setup for mouse clicks
  local line = string.format('%%%s@LualineSwitchTab@%s%%T', self.tabnr, name)
  -- apply highlight
  line = modules.highlight.component_format_highlight(self.highlights[(self.current and 'active' or 'inactive')])
    .. line

  -- apply separators
  if self.options.self.section < 'x' and not self.first then
    local sep_before = self:separator_before()
    line = sep_before .. line
    self.len = self.len + vim.fn.strchars(sep_before)
  elseif self.options.self.section >= 'x' and not self.last then
    local sep_after = self:separator_after()
    line = line .. sep_after
    self.len = self.len + vim.fn.strchars(sep_after)
  end
  return line
end

---apply separator before current tab
---@return string
function Tab:separator_before()
  if self.current or self.aftercurrent then
    return '%S{' .. self.options.section_separators.left .. '}'
  else
    return self.options.component_separators.left
  end
end

---apply separator after current tab
---@return string
function Tab:separator_after()
  if self.current or self.beforecurrent then
    return '%s{' .. self.options.section_separators.right .. '}'
  else
    return self.options.component_separators.right
  end
end

---adds spaces to left and right
function Tab.apply_padding(str, padding)
  local l_padding, r_padding = 1, 1
  if type(padding) == 'number' then
    l_padding, r_padding = padding, padding
  elseif type(padding) == 'table' then
    l_padding, r_padding = padding.left or 0, padding.right or 0
  end
  return string.rep(' ', l_padding) .. str .. string.rep(' ', r_padding)
end

return Tab
