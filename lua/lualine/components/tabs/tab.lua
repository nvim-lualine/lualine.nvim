local lualine_require = require('lualine_require')
local Tab = lualine_require.require('lualine.components.filetype'):extend()

local modules = lualine_require.lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
}

local default_options = {
  colored = true,
}
---intialize a new tab from opts
---@param opts table
function Tab:init(opts)
  assert(opts.tabnr, 'Cannot create Tab without tabnr')
  self.tabnr = opts.tabnr
  self.tabId = opts.tabId
  self.options = vim.tbl_deep_extend('keep', opts.options or {}, default_options)
  self.highlights = opts.highlights
  self.tabs_icon_hl_for = opts.icon_hl_for
  self.tabs_save_icon_hl_for = opts.save_icon_hl_for
end

---returns name for tab. tabs name is the name of buffer in last active window
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

  local file = modules.utils.stl_escape(self.f_name)
  if self.buftype == 'help' then
    return 'help:' .. vim.fn.fnamemodify(file, ':t:r')
  elseif self.buftype == 'terminal' then
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
  local buflist = vim.fn.tabpagebuflist(self.tabnr)
  local winnr = vim.fn.tabpagewinnr(self.tabnr)

  self.bufnr = buflist[winnr]
  self.buftype = vim.fn.getbufvar(self.bufnr, '&buftype')
  self.filetype = vim.fn.getbufvar(self.bufnr, '&filetype')
  self.f_name = vim.api.nvim_buf_get_name(self.bufnr)
  self.f_extension = vim.fn.fnamemodify(self.f_name, ':e')

  self.status = self:label()
  if self.options.fmt then
    self.status = self.options.fmt(self.status or '')
  end
  if self.ellipse then -- show elipsis
    self.status = '...'
  else
    -- different formats for different modes
    if self.options.mode == 0 then
      self.status = tostring(self.tabnr)
    elseif self.options.mode == 1 then
      self.status = self.status
    else
      self.status = string.format('%s %s', tostring(self.tabnr), self.status)
    end
  end

  self.len = vim.fn.strchars(self.status)

  if not self.ellipse then
    self:apply_icon()
    self:apply_modification_icons()
  end

  self:apply_padding()

  -- setup for mouse clicks
  local line = string.format('%%%s@LualineSwitchTab@%s%%T', self.tabnr, self.status)
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
function Tab:apply_padding()
  local l_padding, r_padding, padding = 1, 1, self.options.padding
  if type(padding) == 'number' then
    l_padding, r_padding = padding, padding
  elseif type(padding) == 'table' then
    l_padding, r_padding = padding.left or 0, padding.right or 0
  end
  self.len = self.len + l_padding + r_padding
  self.status = string.rep(' ', l_padding) .. self.status .. string.rep(' ', r_padding)
end

function Tab:apply_modification_icons()
  if not self.options.modification_icons_enabled then
    return
  end

  local elements = {}

  if vim.fn.getbufvar(self.bufnr, '&modified') == 1 then table.insert(elements, '\u{f448}') end
  if vim.fn.getbufvar(self.bufnr, '&modifiable') ~= 1 then table.insert(elements, '\u{f83d}') end

  local status = table.concat(elements, ' ')

  self.len = self.len + vim.fn.strdisplaywidth(status) + 1

  if type(self.options.icon) == 'table' and self.options.icon.align == 'right' then
    self.status = self.status .. ' ' .. status
  else
    self.status = status .. ' ' .. self.status
  end
end

function Tab:icon_hl_for(highlight_color)
  return self.tabs_icon_hl_for(highlight_color)
end

function Tab:save_icon_hl_for(highlight_color, highlight)
  self.tabs_save_icon_hl_for(highlight_color, highlight)
end

function Tab:get_default_hl()
  return "%#" .. self.highlights[(self.current and 'active' or 'inactive')].name .. "#"
end

function Tab:is_focused()
  return not not self.current
end

return Tab
