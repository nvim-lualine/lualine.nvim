local M = {}

function M:new(args)
  args = args or {}
  for index, arg in pairs(args) do self[index] = arg end
  setmetatable(args, self)
  self.__index = self
  return args
end

local function close_pipe(pipe)
  if pipe ~= nil and not pipe:is_closing() then pipe:close() end
end

function M.close_all()
  close_pipe(M.stdin)
  close_pipe(M.stderr)
  close_pipe(M.stdout)
  close_pipe(M.handle)
end

function M.init_options()
  local options = {}
  local args = vim.fn.split(M.cmd, ' ')
  M.stdin = vim.loop.new_pipe(false)
  M.stdout = vim.loop.new_pipe(false)
  M.stderr = vim.loop.new_pipe(false)
  options.command = table.remove(args, 1)
  options.args = args
  options.stdio = {M.stdin, M.stdout, M.stderr}
  if M.cwd then options.cwd = M.cwd end
  if M.env then options.env = M.env end
  if M.detach then options.detach = M.detach end
  return options
end

function M.start()
  local options = M.init_options()
  M.handle = vim.loop.spawn(options.command, options, vim.schedule_wrap(M.stop))
  if M.on_stdout then M.stdout:read_start(vim.schedule_wrap(M.on_stdout)) end
  if M.on_stderr then M.stderr:read_start(vim.schedule_wrap(M.on_stderr)) end
end

function M.stop(code, signal)
  if M.on_exit then M.on_exit(code, signal) end
  if M.on_stdout and M.stdout then M.stdout:read_stop() end
  if M.on_stderr and M.stderr then M.stderr:read_stop() end
  M.close_all()
end

return M
