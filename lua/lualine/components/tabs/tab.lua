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
  self:get_props()
end

function Tab:get_props()
  local buflist = vim.fn.tabpagebuflist(self.tabnr)
  local winnr = vim.fn.tabpagewinnr(self.tabnr)
  local bufnr = buflist[winnr]
  self.file = modules.utils.stl_escape(vim.api.nvim_buf_get_name(bufnr))
  self.filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  self.buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
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
  if self.filetype == 'fugitive' then
    return 'fugitive: ' .. vim.fn.fnamemodify(self.file, ':h:h:t')
  elseif self.buftype == 'help' then
    return 'help:' .. vim.fn.fnamemodify(self.file, ':t:r')
  elseif self.buftype == 'terminal' then
    local match = string.match(vim.split(self.file, ' ')[1], 'term:.*:(%a+)')
    return match ~= nil and match or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif self.file == '' then
    return '[No Name]'
  end
  if self.options.path == 1 then
    return vim.fn.fnamemodify(self.file, ':~:.')
  elseif self.options.path == 2 then
    return vim.fn.fnamemodify(self.file, ':p')
  elseif self.options.path == 3 then
    return vim.fn.fnamemodify(self.file, ':p:~')
  else
    return vim.fn.fnamemodify(self.file, ':t')
  end
end

---returns rendered tab
---@return string
function Tab:render()
  local name = self:label()
  if self.options.fmt then
    name = self.options.fmt(name or '', self)
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
    return '%Z{' .. self.options.section_separators.left .. '}'
  else
    return self.options.component_separators.left
  end
end

---apply separator after current tab
---@return string
function Tab:separator_after()
  if self.current or self.beforecurrent then
    return '%z{' .. self.options.section_separators.right .. '}'
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
