local Harpoon_file = require('lualine.utils.class'):extend()

local modules = require('lualine_require').lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
}


---initialize a new harpoon_file from opts
---@param opts table
function Harpoon_file:init(opts)
  self.infos = opts.infos
  self.options = opts.options
  self.highlights = opts.highlights
  self:get_props()
end

function Harpoon_file:is_current()
  return vim.fn.expand("%:f") == self.infos.filename
end

function Harpoon_file:get_props()
  self.file = self.infos.filename
  self.icon = ''
  if self.options.icons_enabled then
    local dev
    local status, _ = pcall(require, 'nvim-web-devicons')
    if not status then
      dev, _ = '', ''
    else
      dev, _ = require('nvim-web-devicons').get_icon(self.file)
    end
    if dev then
      self.icon = dev .. ' '
    end
  end
end

---returns rendered buffer
---@return string
function Harpoon_file:render()
  local name = self:name()
  if self.options.fmt then
    name = self.options.fmt(name or '', self)
  end

  if self.ellipse then -- show ellipsis
    name = '...'
  else
    name = string.format('%s%s', self.icon, name)
  end
  name = Harpoon_file.apply_padding(name, self.options.padding)
  self.len = vim.fn.strchars(name)

  -- apply highlight
  local line = modules.highlight.component_format_highlight(self.highlights[(self.current and 'active' or 'inactive')])
      .. name

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

---apply separator before current buffer
---@return string
function Harpoon_file:separator_before()
  if self.current or self.aftercurrent then
    return '%Z{' .. self.options.section_separators.left .. '}'
  else
    return self.options.component_separators.left
  end
end

---apply separator after current buffer
---@return string
function Harpoon_file:separator_after()
  if self.current or self.beforecurrent then
    return '%z{' .. self.options.section_separators.right .. '}'
  else
    return self.options.component_separators.right
  end
end

---returns name of current buffer after filtering special buffers
---@return string
function Harpoon_file:name()
  if self.file == '' then
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
function Harpoon_file.apply_padding(str, padding)
  local l_padding, r_padding = 1, 1
  if type(padding) == 'number' then
    l_padding, r_padding = padding, padding
  elseif type(padding) == 'table' then
    l_padding, r_padding = padding.left or 0, padding.right or 0
  end
  return string.rep(' ', l_padding) .. str .. string.rep(' ', r_padding)
end

return Harpoon_file
