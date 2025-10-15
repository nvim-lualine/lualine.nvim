local lualine_require = require('lualine_require')

local M = lualine_require.require('lualine.component'):extend()

local default_options = {
  icon = '', -- f013
  symbols = {
    -- Use standard unicode characters for the spinner and done symbols:
    spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
    done = '✓',
    separator = ' ',
  },
  -- List of LSP names to ignore (e.g., `null-ls`):
  ignore_lsp = {},
  show_name = true,
}

function M:init(options)
  -- Run `super()`.
  M.super.init(self, options)

  -- Apply default options.
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)

  -- Apply symbols.
  self.symbols = self.options.symbols or {}

  ---The difference between the `begin` and `end` progress events for each LSP.
  ---
  ---@type table<integer, integer>
  self.lsp_work_by_client_id = {}

  -- Listen to progress updates only if `nvim` supports the `LspProgress` event.
  pcall(vim.api.nvim_create_autocmd, 'LspProgress', {
    desc = 'Update the Lualine LSP status component with progress',
    group = vim.api.nvim_create_augroup('lualine_lsp_progress', {}),
    ---@param event {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(event)
      local kind = event.data.params.value.kind
      local client_id = event.data.client_id

      local work = self.lsp_work_by_client_id[client_id] or 0
      local work_change = kind == 'begin' and 1 or (kind == 'end' and -1 or 0)

      self.lsp_work_by_client_id[client_id] = math.max(work + work_change, 0)

      -- Refresh Lualine to update the LSP status symbol if it changed.
      if (work == 0 and work_change > 0) or (work == 1 and work_change < 0) then
        require('lualine').refresh()
      end
    end,
  })
end

function M:update_status()
  local result = {}
  local processed = {}

  -- Backwards-compatible function to get the active LSP clients.
  ---@diagnostic disable-next-line: deprecated
  local get_lsp_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  local clients = get_lsp_clients { bufnr = vim.api.nvim_get_current_buf() }

  -- Backwards-compatible function to get the current time in nanoseconds.
  local hrtime = (vim.uv or vim.loop).hrtime
  -- Advance the spinner every 80ms only once, not for each client (otherwise the spinners will skip steps).
  -- NOTE: the spinner symbols table is 1-indexed.
  local spinner_symbol = self.symbols.spinner[math.floor(hrtime() / (1e6 * 80)) % #self.symbols.spinner + 1]

  for _, client in ipairs(clients) do
    local status
    local work = self.lsp_work_by_client_id[client.id]
    if work ~= nil and work > 0 then
      status = spinner_symbol
    elseif work ~= nil and work == 0 then
      status = self.symbols.done
    end

    -- Backwards-compatible function to check if a list contains a value.
    local list_contains = vim.list_contains or vim.tbl_contains
    -- Append the status to the LSP only if it supports progress reporting and is not ignored.
    if not processed[client.name] and not list_contains(self.options.ignore_lsp, client.name) then
      local status_display = ((status and status ~= '') and (' ' .. status) or '')
      if self.options.show_name then
        table.insert(result, client.name .. status_display)
      else
        table.insert(result, status_display)
      end
      processed[client.name] = true
    end
  end

  return table.concat(result, self.symbols.separator)
end

return M
