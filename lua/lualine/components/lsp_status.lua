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
  progress_display = 'spinner',
  show_done = true,
}

local function progress_token(params)
  return vim.inspect(params.token)
end

function M:init(options)
  -- Run `super()`.
  M.super.init(self, options)

  -- Apply default options.
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)

  -- Apply symbols.
  self.symbols = self.options.symbols or {}

  ---Active and completed LSP progress state, indexed by client id and progress token.
  ---
  ---@type table<integer, {active: table<string, {percentage: integer?, seq: integer}>, done: boolean}>
  self.lsp_progress_by_client_id = {}
  self.progress_seq = 0

  -- Listen to progress updates only if `nvim` supports the `LspProgress` event.
  pcall(vim.api.nvim_create_autocmd, 'LspProgress', {
    desc = 'Update the Lualine LSP status component with progress',
    group = vim.api.nvim_create_augroup('lualine_lsp_progress', {}),
    ---@param event {data: {client_id: integer, params: lsp.ProgressParams}}
    callback = function(event)
      local data = event.data or {}
      local params = data.params or {}
      local value = params.value
      if type(value) ~= 'table' then
        return
      end

      local kind = value.kind
      local client_id = data.client_id
      if not client_id or not kind then
        return
      end

      local client_progress = self.lsp_progress_by_client_id[client_id] or { active = {}, done = false }
      local token = progress_token(params)

      if kind == 'end' then
        client_progress.active[token] = nil
        client_progress.done = next(client_progress.active) == nil
      elseif kind == 'begin' or kind == 'report' then
        self.progress_seq = self.progress_seq + 1
        local previous = client_progress.active[token] or {}
        client_progress.active[token] = {
          percentage = value.percentage ~= nil and value.percentage or previous.percentage,
          seq = self.progress_seq,
        }
        client_progress.done = false
      else
        return
      end

      self.lsp_progress_by_client_id[client_id] = client_progress

      -- Refresh Lualine to update spinner, percentage, and done status.
      require('lualine').refresh()
    end,
  })
end

local function select_progress(client_progress)
  local latest
  local latest_with_percentage

  for _, progress in pairs(client_progress.active) do
    if latest == nil or progress.seq > latest.seq then
      latest = progress
    end
    if progress.percentage ~= nil and (latest_with_percentage == nil or progress.seq > latest_with_percentage.seq) then
      latest_with_percentage = progress
    end
  end

  return latest_with_percentage or latest
end

local function current_spinner(symbols)
  local spinner = symbols.spinner or {}
  if #spinner == 0 then
    return ''
  end

  -- Backwards-compatible function to get the current time in nanoseconds.
  local hrtime = (vim.uv or vim.loop).hrtime
  -- Advance the spinner every 80ms only once, not for each client (otherwise the spinners will skip steps).
  -- NOTE: the spinner symbols table is 1-indexed.
  return spinner[math.floor(hrtime() / (1e6 * 80)) % #spinner + 1]
end

function M:update_status()
  local result = {}
  local processed = {}

  -- Backwards-compatible function to get the active LSP clients.
  ---@diagnostic disable-next-line: deprecated
  local get_lsp_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  local clients = get_lsp_clients { bufnr = vim.api.nvim_get_current_buf() }

  local spinner_symbol = current_spinner(self.symbols)
  -- Backwards-compatible function to check if a list contains a value.
  local list_contains = vim.list_contains or vim.tbl_contains

  for _, client in ipairs(clients) do
    local status
    local client_progress = self.lsp_progress_by_client_id[client.id]
    local skip_client = false

    if client_progress ~= nil then
      local progress = select_progress(client_progress)
      if progress ~= nil then
        if self.options.progress_display == 'percentage' and progress.percentage ~= nil then
          status = string.format('%d%%%%', progress.percentage)
        else
          status = spinner_symbol
        end
      elseif client_progress.done then
        if self.options.show_done then
          status = self.symbols.done
        else
          skip_client = true
        end
      end
    end

    -- Append the status to the LSP only if it supports progress reporting and is not ignored.
    if not skip_client and not processed[client.name] and not list_contains(self.options.ignore_lsp, client.name) then
      local status_display = ((status and status ~= '') and (' ' .. status) or '')
      if self.options.show_name then
        table.insert(result, client.name .. status_display)
      elseif status and status ~= '' then
        table.insert(result, status)
      end
      processed[client.name] = true
    end
  end

  return table.concat(result, self.symbols.separator)
end

return M
