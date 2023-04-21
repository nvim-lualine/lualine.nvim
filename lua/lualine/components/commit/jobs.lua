local job = require('lualine.utils.job')

local M = {}

function M._run_job(cmd, callback)
    local output = ''
    local err = ''

    local j = job({
        cmd = {
            'sh', '-c', cmd
        },
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
        end
    })

    if j then
        j:start()
    end
end

function M.check_origin(cwd, callback)
    local cmd = string.format([[cd %s && git remote show]], cwd)
    M._run_job(cmd, function(exit_code, output, _)
        output = output:gsub('\n', '')
        if exit_code ~= 0 or output ~= 'origin' then
            callback(false)
            return
        end

        callback(true)
    end)
end

function M.get_master_name(cwd, callback)
    local cmd = string.format([[cd %s && git remote show origin | grep 'HEAD branch' | cut -d' ' -f5]], cwd)
    M._run_job(cmd, function(exit_code, output, _)
        output = output:gsub('\n', '')
        if exit_code ~= 0 then
            callback(false)
            return
        end
        callback(true, output)
    end)
end

function M.fetch_branch(cwd, name, callback)
    local cmd = string.format([[cd %s && git fetch origin %s]], cwd, name)
    M._run_job(cmd, function(exit_code, _, _)
        if exit_code ~= 0 then
            callback(false)
            return
        end
        callback(true)
    end)
end

function M.check_for_conflict(cwd, source, target, callback)
    -- TODO: reduce command output size
    local cmd = string.format(
        [[cd %s && git merge-tree `git merge-base %s %s` %s %s]],
        cwd,
        source,
        target,
        target,
        source
    )
    M._run_job(cmd, function(exit_code, output, _)
        local has_conflict = false
        if exit_code ~= 0 then
            callback(false, has_conflict)
            return
        end
        local conflict_matched = string.find(output, "<<<<<<<") or 0
        callback(true, conflict_matched > 0)
    end)
end

function M.commit_diff(cwd, source, target, callback)
    local cmd = string.format(
        [[cd %s && git log --oneline %s %s]],
        cwd,
        source,
        target
    )
    M._run_job(cmd, function(exit_code, output, err)
        if exit_code ~= 0 then
            callback(false, -1, err)
            return
        end
        local _, commit_count = output:gsub('\n', '\n')
        callback(true, commit_count)
    end)
end

return M
