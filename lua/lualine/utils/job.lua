-- Wrapper arround job api
local Job = setmetatable({
  start = function(self)
    self.job_id = vim.fn.jobstart(self.args.cmd, self.args)
    return self.job_id > 0
  end,
  stop = function(self)
    if self.killed then return end
    if self.job_id and self.job_id > 0 then vim.fn.jobstop(self.job_id) end
    self.job_id = 0
    self.killed = true
  end,
  -- Wraps callbacks so they are only called when job is alive
  -- This avoids race conditions
  wrap_cb_alive = function(self, name)
    local original_cb = self.args[name]
    if original_cb then
      self.args[name] = function(...)
        if not self.killed then return original_cb(...) end
      end
    end
  end
  }, {
  __call = function(self, args)
    args = vim.deepcopy(args or {})
    if type(args.cmd) == 'string' then args.cmd = vim.split(args.cmd, ' ') end
    self.__index = self
    local job = setmetatable({args = args}, self)
    job:wrap_cb_alive('on_stdout')
    job:wrap_cb_alive('on_stderr')
    job:wrap_cb_alive('on_stdin')
    return job
  end,
})

return Job
