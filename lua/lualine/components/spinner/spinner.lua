local uv = vim.uv or vim.loop

---@class lualine.spinner.Opts
---@field texts? string[] spinner frames text.
---@field initial_delay? integer millisecond
---@field ttl? integer millisecond
---@field interval integer

---@class lualine.spinner.Spinner
---@field id string
---@field text string
---@field private opts lualine.spinner.Opts
---@field private index integer
---@field private enabled boolean
---@field private start_time integer
---@field private active integer
local Spinner = {}
Spinner.__index = Spinner

---@type lualine.spinner.Opts
local default_options = {
  texts = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  interval = 80,
  ttl = 0,
  initial_delay = 200,
}

---@class lualine.spinner.Timer
---@field timer uv.uv_timer_t|nil
---@field ticks table<string, fun()>

---@type table<integer, lualine.spinner.Timer>
local timers = {}

---Start spinner
---@param id string spinner id
---@param interval integer
---@param cb fun()
local function start_spinner(id, interval, cb)
  local t = timers[interval]
  if t and t.timer then
    t.ticks[id] = cb
    return
  end

  t = {
    timer = uv.new_timer(),
    ticks = {},
  }
  t.ticks[id] = cb
  timers[interval] = t

  assert(t.timer, 'Failed to create spinner timer')
  t.timer:start(
    0,
    interval,
    vim.schedule_wrap(function()
      for _, f in pairs(t.ticks) do
        if f then
          f()
        end
      end

      -- combine all spinners refresh event into one.
      require('lualine').refresh()
    end)
  )
end

---Stop spinner
---@param id string spinner id
---@param interval integer
local function stop_spinner(id, interval)
  local t = timers[interval]
  if not t then
    return
  end

  t.ticks[id] = nil
  if next(t.ticks) == nil and t.timer then
    t.timer:stop()
    t.timer:close()
    t.timer = nil
  end
end

---Create a spinner.
---
---@param id string
---@param opts? lualine.spinner.Opts
---@return lualine.spinner.Spinner
local function new(id, opts)
  return setmetatable({
    id = id,
    text = '',

    opts = vim.tbl_extend('keep', opts or {}, default_options),
    index = 1,
    enabled = false,
    start_time = 0,
    active = 0,
  }, Spinner)
end

---Start spinner.
function Spinner:start()
  self.active = self.active + 1
  -- keep refresh start_time
  self.start_time = uv.now()
  if self.enabled then
    return
  end

  self.enabled = true

  local do_start = function()
    -- may stoped already
    if not self.enabled then
      return
    end

    -- spinner really start here.
    self.text = self.opts.texts[self.index]
    local length = #self.opts.texts

    start_spinner(self.id, self.opts.interval, function()
      --- spinner may have been stopped
      if not self.enabled then
        return
      end

      self.index = (self.index % length) + 1
      self.text = self.opts.texts[self.index]
      if self.opts.ttl > 0 and uv.now() - self.start_time >= self.opts.ttl then
        self:stop()
      end
    end)
  end

  if self.opts.initial_delay > 0 then
    vim.defer_fn(do_start, self.opts.initial_delay)
  else
    do_start()
  end
end

---Stop spinner.
function Spinner:stop()
  self.active = self.active - 1
  if not self.enabled or self.active > 0 then
    return
  end

  stop_spinner(self.id, self.opts.interval)

  self.enabled = false
  self.active = 0
  self.text = ''

  require('lualine').refresh()
end

function Spinner:__tostring()
  return self.text
end

local M = {}

---@type table<string, lualine.spinner.Spinner>
local instances = {}

M.default_options = default_options

---@param id string
---@param opts? lualine.spinner.Opts
---@return lualine.spinner.Spinner
function M.new(id, opts)
  local sp = new(id, opts)
  instances[id] = sp
  return sp
end

---Start spinner by id
---@param id string
function M.start(id)
  local sp = instances[id]
  if sp then
    sp:start()
  end
end

---Stop spinner by id
---@param id string
function M.stop(id)
  local sp = instances[id]
  if sp then
    sp:stop()
  end
end

return M
