local Buffer = require('lualine.utils.class'):extend()

local modules = require('lualine_require').lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
}

---initialize a new buffer from opts
---@param opts table
function Buffer:init(opts)
  assert(opts.bufnr, 'Cannot create Buffer without bufnr')
  self.bufnr = opts.bufnr
  self.buf_index = opts.buf_index
  self.options = opts.options
  self.highlights = opts.highlights
  self:get_props()
end

function Buffer:is_current()
  return vim.api.nvim_get_current_buf() == self.bufnr
end

function Buffer:is_alternate()
  return vim.fn.bufnr('#') == self.bufnr and not self:is_current()
end

---setup icons, modified status for buffer
function Buffer:get_props()
  self.file = modules.utils.stl_escape(vim.api.nvim_buf_get_name(self.bufnr))
  self.buftype = vim.api.nvim_buf_get_option(self.bufnr, 'buftype')
  self.filetype = vim.api.nvim_buf_get_option(self.bufnr, 'filetype')
  local modified = self.options.show_modified_status and vim.api.nvim_buf_get_option(self.bufnr, 'modified')
  self.modified_icon = modified and self.options.symbols.modified or ''
  self.alternate_file_icon = self:is_alternate() and self.options.symbols.alternate_file or ''
  self.icon = ''
  if self.options.icons_enabled then
    local dev
    local status, _ = pcall(require, 'nvim-web-devicons')
    if not status then
      dev, _ = '', ''
    elseif self.filetype == 'minideps-confirm' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('minideps-confirm')
    elseif self.filetype == 'minifiles' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('minifiles')
    elseif self.filetype == 'minifiles-help' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('minifiles-help')
    elseif self.filetype == 'mininotify' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('mininotify')
    elseif self.filetype == 'mininotify-history' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('mininotify-history')
    elseif self.filetype == 'minipick' then
      require('nvim-web-devicons').get_icon_by_filetype('minipick')
    elseif self.filetype == 'ministarter' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('ministarter')
    elseif self.filetype == 'neogitcommitselectview' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitcommitselectview')
    elseif self.filetype == 'neogitcommitview' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitcommitview')
    elseif self.filetype == 'neogitconsole' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitconsole')
    elseif self.filetype == 'neogitdiffview' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitdiffview')
    elseif self.filetype == 'neogitgitcommandhistory' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitgitcommandhistory')
    elseif self.filetype == 'neogitlogview' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitlogview')
    elseif self.filetype == 'neogitpopup' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitpopup')
    elseif self.filetype == 'neogitrebasetodo' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitrebasetodo')
    elseif self.filetype == 'neogitreflogview' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitreflogview')
    elseif self.filetype == 'neogitrefsview' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitrefsview')
    elseif self.filetype == 'neogitstatus' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neogitstatus')
    elseif self.filetype == 'nvimtree' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('nvimtree')
    elseif self.filetype == 'overseerform' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('overseerform')
    elseif self.filetype == 'overseerlist' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('overseerlist')
    elseif self.filetype == 'trouble' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('trouble')
    elseif self.filetype == 'aerial' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('aerial')
    elseif self.filetype == 'alpha' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('alpha')
    elseif self.filetype == 'dapui_breakpoints' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('dapui_breakpoints')
    elseif self.filetype == 'dapui_console' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('dapui_console')
    elseif self.filetype == 'dapui_hover' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('dapui_hover')
    elseif self.filetype == 'dapui_scopes' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('dapui_scopes')
    elseif self.filetype == 'dapui_stacks' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('dapui_stacks')
    elseif self.filetype == 'dapui_watches' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('dapui_watches')
    elseif self.filetype == 'dashboard' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('dashboard')
    elseif self.filetype == 'edgy' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('edgy')
    elseif self.filetype == 'fzf' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('fzf')
    elseif self.filetype == 'harpoon' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('harpoon')
    elseif self.filetype == 'lazy' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('lazy')
    elseif self.filetype == 'mason' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('mason')
    elseif self.filetype == 'neo-tree' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neo-tree')
    elseif self.filetype == 'neo-tree-popup' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neo-tree-popup')
    elseif self.filetype == 'neotest-output-panel' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neotest-output-panel')
    elseif self.filetype == 'neotest-summary' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('neotest-summary')
    elseif self.filetype == 'oil' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('oil')
    elseif self.filetype == 'TelescopePrompt' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('TelescopePrompt')
    elseif self.filetype == 'fugitive' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('git')
    elseif self.filetype == 'vimwiki' then
      dev, _ = require('nvim-web-devicons').get_icon_by_filetype('markdown')
    elseif self.buftype == 'terminal' then
      dev, _ = require('nvim-web-devicons').get_icon('zsh')
    elseif vim.fn.isdirectory(self.file) == 1 then
      dev, _ = self.options.symbols.directory, nil
    else
      dev, _ = require('nvim-web-devicons').get_icon(self.file, vim.fn.expand('#' .. self.bufnr .. ':e'))
    end
    if dev then
      self.icon = dev .. ' '
    end
  end
end

---returns line configured for handling mouse click
---@param name string
---@return string
function Buffer:configure_mouse_click(name)
  return string.format('%%%s@LualineSwitchBuffer@%s%%T', self.bufnr, name)
end

---returns rendered buffer
---@return string
function Buffer:render()
  local name = self:name()
  if self.options.fmt then
    name = self.options.fmt(name or '', self)
  end

  if self.ellipse then -- show ellipsis
    name = '...'
  else
    name = self:apply_mode(name)
  end
  name = Buffer.apply_padding(name, self.options.padding)
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

---apply separator before current buffer
---@return string
function Buffer:separator_before()
  if self.current or self.aftercurrent then
    return '%Z{' .. self.options.section_separators.left .. '}'
  else
    return self.options.component_separators.left
  end
end

---apply separator after current buffer
---@return string
function Buffer:separator_after()
  if self.current or self.beforecurrent then
    return '%z{' .. self.options.section_separators.right .. '}'
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
function Buffer.apply_padding(str, padding)
  local l_padding, r_padding = 1, 1
  if type(padding) == 'number' then
    l_padding, r_padding = padding, padding
  elseif type(padding) == 'table' then
    l_padding, r_padding = padding.left or 0, padding.right or 0
  end
  return string.rep(' ', l_padding) .. str .. string.rep(' ', r_padding)
end

function Buffer:apply_mode(name)
  if self.options.mode == 0 then
    return string.format('%s%s%s%s', self.alternate_file_icon, self.icon, name, self.modified_icon)
  end

  if self.options.mode == 1 then
    return string.format('%s%s %s%s', self.alternate_file_icon, self.buf_index or '', self.icon, self.modified_icon)
  end

  if self.options.mode == 2 then
    return string.format(
      '%s%s %s%s%s',
      self.alternate_file_icon,
      self.buf_index or '',
      self.icon,
      name,
      self.modified_icon
    )
  end

  if self.options.mode == 3 then
    return string.format('%s%s %s%s', self.alternate_file_icon, self.bufnr or '', self.icon, self.modified_icon)
  end

  -- if self.options.mode == 4 then
  return string.format('%s%s %s%s%s', self.alternate_file_icon, self.bufnr or '', self.icon, name, self.modified_icon)
end

return Buffer
