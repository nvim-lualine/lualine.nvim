-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

--- wrapper around job api
--- creates a job handler when called
local Job = setmetatable({
  --- start the job
  start = function(self)
    self.job_id = vim.fn.jobstart(self.args.cmd, self.args)
    return self.job_id > 0
  end,
  --- stop the job. Also immediately disables io from the job.
  stop = function(self)
    if self.killed then
      return
    end
    if self.job_id and self.job_id > 0 then
      vim.fn.jobstop(self.job_id)
    end
    self.job_id = 0
    self.killed = true
  end,
  -- Wraps callbacks so they are only called when job is alive
  -- This avoids race conditions
  wrap_cb_alive = function(self, name)
    local original_cb = self.args[name]
    if original_cb then
      self.args[name] = function(...)
        if not self.killed then
          return original_cb(...)
        end
      end
    end
  end,
}, {
  ---create new job handler
  ---@param self table base job table
  ---@param args table same args as jobstart except cmd is also passed in part of it
  ---@return table new job handler
  __call = function(self, args)
    args = vim.deepcopy(args or {})
    if type(args.cmd) == 'string' then
      args.cmd = vim.split(args.cmd, ' ')
    end
    self.__index = self
    local job = setmetatable({ args = args }, self)
    job:wrap_cb_alive('on_stdout')
    job:wrap_cb_alive('on_stderr')
    job:wrap_cb_alive('on_stdin')
    return job
  end,
})

return Job
