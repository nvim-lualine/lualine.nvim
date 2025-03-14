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
}

---Advances the spinner every 80ms (or just once if precise time measurement is not supported) and returns the new
---spinner symbol.
function M:__advance_spinner()
  if vim.uv then
    self.__spinner_index = math.floor(vim.uv.hrtime() / (1e6 * 80))
  else
    self.__spinner_index = (self.__spinner_index or 0) + 1
  end
  self.__spinner_index = self.__spinner_index % #self.symbols.spinner
  -- The spinner symbols table is 1-indexed.
  return self.symbols.spinner[self.__spinner_index + 1]
end

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
  local bufnr = vim.api.nvim_get_current_buf()
  local result = {}

  -- Retrieve the active LSPs in the current buffer in a backwards-compatible way.
  local clients
  if vim.lsp.get_clients then
    clients = vim.lsp.get_clients { bufnr = bufnr }
  else
    ---@diagnostic disable-next-line: deprecated
    clients = vim.lsp.get_active_clients { bufnr = bufnr }
  end

  -- Advance the spinner only once, not for each client (otherwise the spinners will skip steps).
  local spinner_symbol = self:__advance_spinner()

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
    if not list_contains(self.options.ignore_lsp, client.name) then
      table.insert(result, client.name .. (status and ' ' .. status or ''))
    end
  end
  return table.concat(result, self.symbols.separator)
end

return M
