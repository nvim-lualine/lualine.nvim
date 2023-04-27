local job = require('lualine.utils.job')

local M = {}

function M._run_job(cmd, cwd, callback)
  local output = ''
  local err = ''

  local j = job {
    cmd = {
      'sh',
      '-c',
      cmd,
    },
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      output = table.concat(data, '\n')
    end,
    on_stderr = function(_, data)
      err = table.concat(data, '\n')
    end,
    on_exit = function(_, exit_code)
      callback(exit_code, output, err)
    end,
  }

  if j then
    j:start()
  end
end

function M.check_origin(cwd, callback)
  M._run_job('git remote show', cwd, function(exit_code, output, _)
    output = output:gsub('\n', '')
    if exit_code ~= 0 or output ~= 'origin' then
      callback(false)
      return
    end

    callback(true)
  end)
end

function M.get_master_name(cwd, callback)
  M._run_job("git remote show origin | grep 'HEAD branch' | cut -d' ' -f5", cwd, function(exit_code, output, _)
    output = output:gsub('\n', '')
    if exit_code ~= 0 then
      callback(false)
      return
    end
    callback(true, output)
  end)
end

function M.fetch_branch(cwd, name, callback)
  local cmd = string.format([[git fetch origin %s]], name)
  M._run_job(cmd, cwd, function(exit_code, _, _)
    if exit_code ~= 0 then
      callback(false)
      return
    end
    callback(true)
  end)
end

function M.check_for_conflict(cwd, source, target, callback)
  local cmd =
    string.format([[git merge-tree `git merge-base %s %s` %s %s | grep '<<<<<<<']], source, target, target, source)
  M._run_job(cmd, cwd, function(exit_code, _, _)
    if exit_code ~= 0 then
      -- grep that finds nothing returns exit code 1
      callback(true, false)
      return
    end
    callback(true, true)
  end)
end

function M.commit_diff(cwd, source, target, callback)
  local cmd = string.format([[git log --oneline %s %s]], source, target)
  M._run_job(cmd, cwd, function(exit_code, output, err)
    if exit_code ~= 0 then
      callback(false, -1, err)
      return
    end
    local _, commit_count = output:gsub('\n', '\n')
    callback(true, commit_count)
  end)
end

return M
