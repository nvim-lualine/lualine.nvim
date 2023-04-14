local M = {}

local require = require('lualine_require').require
local utils = require('lualine.utils.utils')
local job = require('lualine.utils.job')

local current_git_dir = ''
-- os specific path separator
local sep = package.config:sub(1, 1)

local git_dir_cache = {}  -- Stores git paths that we already know of, map file dir to git_dir
local git_repo_cache = {} -- Stores information about git repository commits

function fetchBranch(cwd, name, callback)
    fetch_job = job({
        cmd = {
            'sh', '-c',
            string.format([[cd %s && git fetch origin %s]],
                cwd,
                name)
        },
        on_exit = function(_, exit_code)
            if exit_code ~= 0 then
                callback(false)
                return
            end
            callback(true)
        end
    })
    if fetch_job then
        fetch_job:start()
    end
end

function commitDiff(cwd, source, target, callback)
    local diff_output = ''
    diff_job = job({
        cmd = {
            'sh', '-c',
            string.format(
                [[cd %s && git log --oneline %s %s]],
                cwd,
                source,
                target)
        },
        on_stdout = function(_, data)
            diff_output = diff_output .. table.concat(data, '\n')
        end,
        on_exit = function(_, exit_code)
            if exit_code ~= 0 then
                callback(false, -1)
                return
            end
            local _, commit_count = diff_output:gsub('\n', '\n')
            callback(true, commit_count)
        end
    })
    if diff_job then
        diff_job:start()
    end
end

---returns full path to git directory for dir_path or current directory
---@param dir_path string|nil
---@return string
function M.find_git_dir(dir_path)
    -- get file dir so we can search from that dir
    local file_dir = dir_path or vim.fn.expand('%:p:h')
    local root_dir = file_dir
    local git_dir
    -- Search upward for .git file or folder
    while root_dir do
        if git_dir_cache[root_dir] then
            git_dir = git_dir_cache[root_dir]
            break
        end
        local git_path = root_dir .. sep .. '.git'
        local git_file_stat = vim.loop.fs_stat(git_path)
        if git_file_stat then
            if git_file_stat.type == 'directory' then
                git_dir = git_path
            elseif git_file_stat.type == 'file' then
                -- separate git-dir or submodule is used
                local file = io.open(git_path)
                if file then
                    git_dir = file:read()
                    git_dir = git_dir and git_dir:match('gitdir: (.+)$')
                    file:close()
                end
                -- submodule / relative file path
                if git_dir and git_dir:sub(1, 1) ~= sep and not git_dir:match('^%a:.*$') then
                    git_dir = git_path:match('(.*).git') .. git_dir
                end
            end
            if git_dir then
                local head_file_stat = vim.loop.fs_stat(git_dir .. sep .. 'HEAD')
                if head_file_stat and head_file_stat.type == 'file' then
                    break
                else
                    git_dir = nil
                end
            end
        end
        root_dir = root_dir:match('(.*)' .. sep .. '.-')
    end

    git_dir_cache[file_dir] = git_dir
    return git_dir
end

function M.watch_repo(dir_path)
    local git_dir = M.find_git_dir(dir_path)

    if git_dir == nil then
        for _, v in pairs(git_repo_cache) do
            v.timer:stop()
        end
        return -- noting to do
    end

    -- Stop all timers before watching new repository
    if git_dir ~= current_git_dir then
        for _, v in pairs(git_repo_cache) do
            v.timer:stop()
        end
    end

    if dir_path == nil and current_git_dir ~= git_dir then
        current_git_dir = git_dir
    end

    local git_repo = git_repo_cache[git_dir]

    if git_repo == nil then
        local timer = vim.loop.new_timer()
        git_repo = {
            dir = git_dir,
            timer = timer,
            master_commit_count = 0,
            unpushed_commit_count = 0,
            unpulled_commit_count = 0,
        }
        git_repo_cache[git_dir] = git_repo

        local start_timer = function(git_data)
            timer:start(0, M.opts.interval, vim.schedule_wrap(function()
                local cwd = git_data.dir:sub(1, -6)
                -- Diff against master
                fetchBranch(cwd, M.opts.master_name, function(success)
                    if not success then
                        print("failed to fetch branch" .. M.opts.master_name)
                        return
                    end

                    commitDiff(cwd, 'origin/' .. M.opts.master_name, '^@', function(success, count)
                        if not success then
                            print("git log failed")
                            return
                        end

                        git_data.master_commit_count = count
                    end)
                end)

                -- Diff against current branch upstream
                fetchBranch(cwd, '@', function(success)
                    if not success then
                        print("failed to fetch branch @")
                        return
                    end

                    commitDiff(cwd, '@', '^@{upstream}', function(success, count)
                        if not success then
                            print("git log failed")
                            return
                        end

                        git_data.unpushed_commit_count = count
                    end)

                    commitDiff(cwd, '^@', '@{upstream}', function(success, count)
                        if not success then
                            print("git log failed")
                            return
                        end

                        git_data.unpulled_commit_count = count
                    end)
                end)
            end))
        end
        start_timer(git_repo)
        return
    end

    -- restart timer
    git_repo.timer:again()
end

function M.init(opts)
    M.opts = opts
    M.watch_repo()
    utils.define_autocmd('BufEnter', "lua require'lualine.components.commit.commits_status'.watch_repo()")
end

function M.status(bufnr)
    -- TODO: filter terminal, fugitive, telescope buffers etc...
    local file_dir
    if bufnr then
        local bufname = vim.fn.bufname(bufnr)
        file_dir = vim.fn.fnamemodify(bufname, ':p:h')
    else
        file_dir = vim.fn.expand('%:p:h')
    end

    local git_dir = git_dir_cache[file_dir]
    if git_dir == nil then
        return ''
    end

    local repo = git_repo_cache[git_dir]

    return (
        M.opts.unpulled_master_icon .. tostring(repo.master_commit_count) ..
        ' ' .. M.opts.unpulled_icon .. tostring(repo.unpulled_commit_count) ..
        ' ' .. M.opts.unpushed_icon .. tostring(repo.unpushed_commit_count))
end

return M
