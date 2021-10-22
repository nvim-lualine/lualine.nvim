local highlight = require 'lualine.highlight'
local Buffer = require('lualine.utils.class'):extend()

---intialize a new buffer from opts
---@param opts table
function Buffer:init(opts)
  assert(opts.bufnr, 'Cannot create Buffer without bufnr')
  self.bufnr = opts.bufnr
  self.options = opts.options
  self.highlights = opts.highlights
  self:get_props()
end

---setup icons, modified status for buffer
function Buffer:get_props()
  self.file = vim.fn.bufname(self.bufnr)
  self.buftype = vim.api.nvim_buf_get_option(self.bufnr, 'buftype')
  self.filetype = vim.api.nvim_buf_get_option(self.bufnr, 'filetype')
  local modified = self.options.show_modified_status and vim.api.nvim_buf_get_option(self.bufnr, 'modified')
  local modified_icon = self.options.icons_enabled and ' ●' or ' +'
  self.modified_icon = modified and modified_icon or ''
  self.icon = ''
  if self.options.icons_enabled then
    local dev
    local status, _ = pcall(require, 'nvim-web-devicons')
    if not status then
      dev, _ = '', ''
    elseif self.filetype == 'TelescopePrompt' then
      dev, _ = require('nvim-web-devicons').get_icon 'telescope'
    elseif self.filetype == 'fugitive' then
      dev, _ = require('nvim-web-devicons').get_icon 'git'
    elseif self.filetype == 'vimwiki' then
      dev, _ = require('nvim-web-devicons').get_icon 'markdown'
    elseif self.buftype == 'terminal' then
      dev, _ = require('nvim-web-devicons').get_icon 'zsh'
    elseif vim.fn.isdirectory(self.file) == 1 then
      dev, _ = '', nil
    else
      dev, _ = require('nvim-web-devicons').get_icon(self.file, vim.fn.expand('#' .. self.bufnr .. ':e'))
    end
    if dev then
      self.icon = dev .. ' '
    end
  end
end

---returns rendered buffer
---@return string
function Buffer:render()
  local name
  if self.ellipse then -- show elipsis
    name = '...'
  else
    name = string.format(' %s%s%s ', self.icon, self:name(), self.modified_icon)
  end
  self.len = vim.fn.strchars(name)

  -- setup for mouse clicks
  local line = string.format('%%%s@LualineSwitchBuffer@%s%%T', self.bufnr, name)
  -- apply highlight
  line = highlight.component_format_highlight(self.highlights[(self.current and 'active' or 'inactive')]) .. line

  -- apply separators
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

---apply separator before current buffer
---@return string
function Buffer:separator_before()
  if self.current or self.aftercurrent then
    return '%S{' .. self.options.section_separators.left .. '}'
  else
    return self.options.component_separators.left
  end
end

---apply separator after current buffer
---@return string
function Buffer:separator_after()
  if self.current or self.beforecurrent then
    return '%s{' .. self.options.section_separators.right .. '}'
  else
    return self.options.component_separators.right
  end
end

---returns name of current buffer after filtering special buffers
---@return string
function Buffer:name()
  if self.options.filetype_names[self.filetype] then
    return self.options.filetype_names[self.filetype]
  elseif self.buftype == 'help' then
    return 'help:' .. vim.fn.fnamemodify(self.file, ':t:r')
  elseif self.buftype == 'terminal' then
    local match = string.match(vim.split(self.file, ' ')[1], 'term:.*:(%a+)')
    return match ~= nil and match or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif vim.fn.isdirectory(self.file) == 1 then
    return vim.fn.fnamemodify(self.file, ':p:.')
  elseif self.file == '' then
    return '[No Name]'
  end
  return self.options.show_filename_only and vim.fn.fnamemodify(self.file, ':t')
    or vim.fn.pathshorten(vim.fn.fnamemodify(self.file, ':p:.'))
end

return Buffer
