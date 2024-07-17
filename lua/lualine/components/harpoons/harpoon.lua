local Harpoon = require('lualine.utils.class'):extend()
local harpoon_plug = require('harpoon')

local modules = require('lualine_require').lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
}

---initialize a new harpoon from opts
---@param opts table
function Harpoon:init(opts)
  assert(opts.bufnr or opts.hpnr, 'Cannot create Harpoon without bufnr')
  self.hpnr = opts.hpnr
  self.bufnr = opts.bufnr
  self.options = opts.options
  self.highlights = opts.highlights
  self:get_props()
end

function Harpoon:is_current()
  return self.bufnr and vim.api.nvim_get_current_buf() == self.bufnr
end

function Harpoon:is_alternate()
  return vim.fn.bufnr('#') == self.hpnr and not self:is_current()
end

---setup icons, modified status for harpoon
function Harpoon:get_props()
  if self.bufnr then
    self.file = modules.utils.stl_escape(vim.api.nvim_buf_get_name(self.bufnr))
    self.buftype = vim.api.nvim_get_option_value('buftype', { buf = self.bufnr })
    self.filetype = vim.api.nvim_get_option_value('filetype', { buf = self.bufnr })
  else
    self.file = harpoon_plug:list().items[self.hpnr].value
    self.buftype = nil
    self.filetype = self.file:match('^.+%.(.+)$')
  end

  -- remove the oil prefix
  if self.filetype == 'oil' then
    self.file = string.sub(self.file, 7)
  end

  local modified = self.bufnr and vim.api.nvim_get_option_value('modified', { buf = self.bufnr })
  self.modified_icon = modified and self.options.symbols.modified or ''
  self.alternate_file_icon = self:is_alternate() and self.options.symbols.alternate_file or ''
  self.icon = ''
  if self.options.icons_enabled then
    local dev
    local status, _ = pcall(require, 'nvim-web-devicons')
    if not status then
      dev, _ = '', ''
    elseif self.filetype == 'TelescopePrompt' then
      dev, _ = require('nvim-web-devicons').get_icon('telescope')
    elseif self.filetype == 'fugitive' then
      dev, _ = require('nvim-web-devicons').get_icon('git')
    elseif self.filetype == 'vimwiki' then
      dev, _ = require('nvim-web-devicons').get_icon('markdown')
    elseif self.buftype == 'terminal' then
      dev, _ = require('nvim-web-devicons').get_icon('zsh')
    elseif vim.fn.isdirectory(self.file) == 1 then
      dev, _ = self.options.symbols.directory, nil
    else
      dev, _ = require('nvim-web-devicons').get_icon(self.file, vim.fn.expand(self.filetype))
    end
    if dev then
      self.icon = dev .. ' '
    end
  end
end

---returns line configured for handling mouse click
---@param name string
---@return string
function Harpoon:configure_mouse_click(name)
  if self.hpnr then
    return string.format('%%%s@LualineSwitchHarpoon@%s%%T', self.hpnr, name)
  else
    return name
  end
end

---returns rendered harpoon
---@return string
function Harpoon:render()
  local name = self:name()
  if self.options.fmt then
    name = self.options.fmt(name or '', self)
  end

  if self.ellipse then -- show ellipsis
    name = '...'
  else
    name = self:apply_mode(name)
  end
  name = Harpoon.apply_padding(name, self.options.padding)
  self.len = vim.fn.strchars(name)

  -- setup for mouse clicks
  local line = self:configure_mouse_click(name)
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

---apply separator before current harpoon
---@return string
function Harpoon:separator_before()
  if self.current or self.aftercurrent then
    return '%Z{' .. self.options.section_separators.left .. '}'
  else
    return self.options.component_separators.left
  end
end

---apply separator after current harpoon
---@return string
function Harpoon:separator_after()
  if self.current or self.beforecurrent then
    return '%z{' .. self.options.section_separators.right .. '}'
  else
    return self.options.component_separators.right
  end
end

---returns name of current harpoon after filtering special harpoons
---@return string
function Harpoon:name()
  if self.options.filetype_names[self.filetype] then
    return self.options.filetype_names[self.filetype]
  elseif self.buftype == 'help' then
    return 'help:' .. vim.fn.fnamemodify(self.file, ':t:r')
  elseif self.buftype == 'terminal' then
    local match = string.match(vim.split(self.file, ' ')[1], 'term:.*:(%a+)')
    return match ~= nil and match or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif self.buftype == 'quickfix' then
    local is_loclist = 0 ~= vim.fn.getloclist(0, { filewinid = 1 }).filewinid
    return is_loclist and 'Location list' or 'Quickfix List'
  elseif vim.fn.isdirectory(self.file) == 1 then
    return vim.fn.fnamemodify(self.file, ':p:.')
  elseif self.file == '' then
    return '[No Name]'
  end

  local name
  if self.options.show_filename_only then
    name = vim.fn.fnamemodify(self.file, ':t')
  else
    name = vim.fn.pathshorten(vim.fn.fnamemodify(self.file, ':p:.'))
  end
  if self.options.hide_filename_extension then
    name = vim.fn.fnamemodify(name, ':r')
  end
  return name
end

---adds spaces to left and right
function Harpoon.apply_padding(str, padding)
  local l_padding, r_padding = 1, 1
  if type(padding) == 'number' then
    l_padding, r_padding = padding, padding
  elseif type(padding) == 'table' then
    l_padding, r_padding = padding.left or 0, padding.right or 0
  end
  return string.rep(' ', l_padding) .. str .. string.rep(' ', r_padding)
end

function Harpoon:apply_mode(name)
  if self.options.mode == 0 then
    return string.format('%s%s%s%s', self.alternate_file_icon, self.icon, name, self.modified_icon)
  end

  if self.options.mode == 1 then
    return string.format('%s%s %s%s', self.alternate_file_icon, self.hpnr or '', self.icon, self.modified_icon)
  end

  -- if self.options.mode == 2 then
  return string.format('%s%s %s%s%s', self.alternate_file_icon, self.hpnr or '', self.icon, name, self.modified_icon)
end

return Harpoon
