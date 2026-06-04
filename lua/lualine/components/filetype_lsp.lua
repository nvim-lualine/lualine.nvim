-- Combined filetype + lsp_status lualine component.
-- Shows the buffer filetype (with devicon) and, when any LSP is attached,
-- appends its name and progress symbol after a configurable separator.
-- Because the two parts live in one component the surrounding padding is
-- always correct – no empty-right-padding artefact when no LSP is active.

-- Original filetype component license
-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.

local lualine_require = require('lualine_require')
local modules = lualine_require.lazy_require {
  highlight = 'lualine.highlight',
  utils = 'lualine.utils.utils',
}
local M = lualine_require.require('lualine.component'):extend()

-- ── Default options ────────────────────────────────────────────────────────

local default_options = {
  -- filetype options
  colored = true, -- colour the devicon with its highlight group
  icon_only = false, -- show only the icon, hide the filetype text

  -- lsp options
  lsp_icon = '', -- icon prepended to the LSP portion (set '' to hide)
  lsp_separator = '  ', -- string placed between the filetype and LSP parts
  symbols = {
    spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
    done = '✓',
    separator = ' ', -- separator between multiple LSP names
  },
  ignore_lsp = {}, -- list of LSP client names to hide, e.g. { 'null-ls' }
  show_name = true, -- show the LSP client name alongside its symbol
}

function M:init(options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
  self.symbols = self.options.symbols or {}

  -- Cache for coloured devicon highlight groups.
  self.icon_hl_cache = {}

  -- Per-client work counter: >0 means busy, ==0 means just finished.
  ---@type table<integer, integer>
  self.lsp_work_by_client_id = {}

  -- Track LSP progress so the spinner stays live.
  pcall(vim.api.nvim_create_autocmd, 'LspProgress', {
    desc = 'Refresh lualine filetype_lsp on LSP progress',
    group = vim.api.nvim_create_augroup('lualine_filetype_lsp_progress', { clear = true }),
    ---@param event {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(event)
      local kind = event.data.params.value.kind
      local cid = event.data.client_id
      local work = self.lsp_work_by_client_id[cid] or 0
      local delta = kind == 'begin' and 1 or (kind == 'end' and -1 or 0)
      self.lsp_work_by_client_id[cid] = math.max(work + delta, 0)
      -- Only refresh on transitions to avoid hammering lualine.
      if (work == 0 and delta > 0) or (work == 1 and delta < 0) then
        require('lualine').refresh()
      end
    end,
  })
end

-- Returns the raw filetype string (used by the base class before apply_icon).
function M.update_status()
  return modules.utils.stl_escape(vim.bo.filetype or '')
end

-- Returns the combined LSP names + symbols, or nil when nothing is attached.
function M:get_lsp_status()
  ---@diagnostic disable-next-line: deprecated
  local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  local clients = get_clients { bufnr = vim.api.nvim_get_current_buf() }
  local list_contains = vim.list_contains or vim.tbl_contains

  if #clients == 0 then
    return nil
  end

  local hrtime = (vim.uv or vim.loop).hrtime
  local spinner = self.symbols.spinner[math.floor(hrtime() / (1e6 * 80)) % #self.symbols.spinner + 1]

  local result = {}
  local processed = {}

  for _, client in ipairs(clients) do
    if not processed[client.name] and not list_contains(self.options.ignore_lsp, client.name) then
      local work = self.lsp_work_by_client_id[client.id]
      local symbol = (work ~= nil and work > 0) and spinner or (work ~= nil and work == 0) and self.symbols.done or nil

      local symbol_str = (symbol and symbol ~= '') and (' ' .. symbol) or ''

      local entry
      if self.options.show_name then
        entry = client.name .. symbol_str
      elseif symbol_str ~= '' then
        entry = symbol_str
      end

      if entry and entry ~= '' then
        table.insert(result, entry)
      end

      processed[client.name] = true
    end
  end

  if #result == 0 then
    return nil
  end
  return table.concat(result, self.symbols.separator)
end

function M:apply_icon()
  local icon, icon_hl_group

  if self.options.icons_enabled then
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    if ok then
      icon, icon_hl_group = devicons.get_icon(vim.fn.expand('%:t'))
      if icon == nil then
        icon, icon_hl_group = devicons.get_icon_by_filetype(vim.bo.filetype)
      end
      -- Fallback so there is always *something*.
      if icon == nil then
        icon = ''
        icon_hl_group = 'DevIconDefault'
      end
    else
      -- vim-devicons fallback
      ok = vim.fn.exists('*WebDevIconsGetFileTypeSymbol')
      if ok ~= 0 then
        icon = vim.fn.WebDevIconsGetFileTypeSymbol()
      end
    end
  end

  if icon then
    local icon_str = icon .. ' '

    if self.options.colored and icon_hl_group then
      local color = modules.utils.extract_highlight_colors(icon_hl_group, 'fg')
      if color then
        local default_hl = self:get_default_hl()
        local icon_hl = self.icon_hl_cache[color]
        if not icon_hl or not modules.highlight.highlight_exists(icon_hl.name .. '_normal') then
          icon_hl = self:create_hl({ fg = color }, icon_hl_group)
          self.icon_hl_cache[color] = icon_hl
        end
        icon_str = self:format_hl(icon_hl) .. icon_str .. default_hl
      end
    end

    if self.options.icon_only then
      self.status = icon_str
    elseif type(self.options.icon) == 'table' and self.options.icon.align == 'right' then
      self.status = self.status .. ' ' .. icon_str
    else
      self.status = icon_str .. self.status
    end
  end

  local lsp = self:get_lsp_status()
  if lsp then
    local lsp_part = lsp
    local lsp_icon = self.options.lsp_icon
    if lsp_icon and lsp_icon ~= '' then
      lsp_part = lsp_icon .. ' ' .. lsp_part
    end
    self.status = self.status .. self.options.lsp_separator .. lsp_part
  end
end

return M
