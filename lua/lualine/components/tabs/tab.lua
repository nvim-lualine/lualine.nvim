local highlight = require 'lualine.highlight'
local Tab = require('lualine.utils.class'):extend()

function Tab:init(opts)
  assert(opts.tabnr, 'Cannot create Tab without tabnr')
  self.tabnr = opts.tabnr
  self.options = opts.options
  self.highlights = opts.highlights
end

function Tab:label()
  local buflist = vim.fn.tabpagebuflist(self.tabnr)
  local winnr = vim.fn.tabpagewinnr(self.tabnr)
  local bufnr = buflist[winnr]
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, '&buftype')
  if buftype == 'help' then
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

function Tab:render()
  local name
  if self.ellipse then
    name = '...'
  else
    if self.options.mode == 0 then
      name = string.format('%s%s ', (self.last or not self.first) and ' ' or '', tostring(self.tabnr))
    elseif self.options.mode == 1 then
      name = string.format('%s%s ', (self.last or not self.first) and ' ' or '', self:label())
    else
      name = string.format('%s%s %s ', (self.last or not self.first) and ' ' or '', tostring(self.tabnr), self:label())
    end
  end
  self.len = #name
  local line = string.format('%%%s@LualineSwitchTab@%s%%T', self.tabnr, name)
  line = highlight.component_format_highlight(self.highlights[(self.current and 'active' or 'inactive')]) .. line

  if self.options.self.section < 'lualine_x' and not self.first then
    local sep_before = self:separator_before()
    line = sep_before .. line
    self.len = self.len + vim.fn.strchars(sep_before)
  elseif self.options.self.section >= 'lualine_x' and not self.last then
    local sep_after = self:separator_after()
    line = line .. sep_after
    self.len = self.len + vim.fn.strchars(sep_after)
  end
  return line
end

function Tab:separator_before()
  if self.current or self.aftercurrent then
    return '%S{' .. self.options.section_separators.left .. '}'
  else
    return self.options.component_separators.left
  end
end

function Tab:separator_after()
  if self.current or self.beforecurrent then
    return '%s{' .. self.options.section_separators.right .. '}'
  else
    return self.options.component_separators.right
  end
end

return Tab
