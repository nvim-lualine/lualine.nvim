local M = {}

local require = require('lualine_require').require
local utils = require('lualine.utils.utils')
local job = require('lualine.utils.job')

local current_git_dir = ''
-- os specific path separator
local sep = package.config:sub(1, 1)

local git_dir_cache = {}  -- Stores git paths that we already know of, map file dir to git_dir
local git_repo_cache = {} -- Stores information about git repository commits

function checkOrigin(cwd, callback)
    local output = ''
    fetch_job = job({
        cmd = {
            'sh', '-c',
            string.format([[cd %s && git remote show]],
                cwd)
        },
        on_stdout = function(_, data)
            output = output .. table.concat(data, '')
        end,
        on_exit = function(_, exit_code)
            if exit_code ~= 0 or output ~= 'origin' then
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

function getMasterName(cwd, callback)
    local output = ''
    fetch_job = job({
        cmd = {
            'sh', '-c',
            string.format([[cd %s && git remote show origin | grep 'HEAD branch' | cut -d' ' -f5]],
                cwd)
        },
        on_stdout = function(_, data)
            output = output .. table.concat(data, '')
        end,
        on_exit = function(_, exit_code)
            if exit_code ~= 0 then
                callback(false)
                return
            end
            callback(true, output)
        end
    })
    if fetch_job then
        fetch_job:start()
    end
end

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
    local err_output = ''
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
        on_stderr = function(_, data)
            err_output = err_output .. table.concat(data, '\n')
        end,
        on_exit = function(_, exit_code)
            if exit_code ~= 0 then
                callback(false, -1, err_output)
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

function M.watch_head(repo)
    -- Update the state of changed git repo here.
    -- May not be the current buffer.
    if M.opts.diff_against_master then
        repo:update_master()
    end
    repo:update_current()

    repo.file_changed:stop()
    local head_file = repo.dir .. sep .. 'HEAD'

    local lines = {}
    for line in io.lines(head_file) do
        lines[#lines + 1] = line
    end
    local ref = lines[1]:gsub("ref: ", "")
    local branch_name = ref:gsub("refs/heads/", "")
    if ref ~= repo.ref then
        repo.ref = ref
        repo.branch_name = branch_name
        repo.no_upstream = false -- reset as we don't know, check is done on first diff attempt
        -- if the head changes, we should reset the watch_ref
        M.watch_ref(repo)
        if repo.origin_set then
            M.watch_remote_ref(repo)
        end
    end

    repo.file_changed:start(
        head_file,
        sep ~= '\\' and {} or 1000,
        vim.schedule_wrap(function()
            M.watch_head(repo)
        end)
    )
end

function M.watch_ref(repo)
    -- Not sure if the below is right in this case.
    if M.opts.diff_against_master then
        repo:update_master()
    end
    repo:update_current()

    repo.branch_tip_changed:stop()
    local branch_tip_file = repo.dir .. sep .. repo.ref
    repo.branch_tip_changed:start(
        branch_tip_file,
        sep ~= '\\' and {} or 1000,
        vim.schedule_wrap(function()
            M.watch_ref(repo)
        end)
    )
end

function M.watch_remote_ref(repo)
    -- Not sure if the below is right in this case.
    if M.opts.diff_against_master then
        repo:update_master()
    end
    repo:update_current()
    print("commit changed")

    repo.remote_branch_tip_changed:stop()
    local remote_branch_tip_file = repo.dir .. sep .. repo.ref:gsub("heads", "remotes/origin")
    repo.remote_branch_tip_changed:start(
        remote_branch_tip_file,
        sep ~= '\\' and {} or 1000,
        vim.schedule_wrap(function()
            M.watch_remote_ref(repo)
        end)
    )
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
            git_cwd = git_dir:sub(1, -6), -- cut  '/.git' suffix
            ref = '',
            master_name = M.opts.master_name or nil,
            branch_name = '',
            origin_set = false,
            no_upstream = false,
            timer = timer,
            file_changed = sep ~= '\\' and vim.loop.new_fs_event() or vim.loop.new_fs_poll(),
            branch_tip_changed = sep ~= '\\' and vim.loop.new_fs_event() or vim.loop.new_fs_poll(),
            remote_branch_tip_changed = sep ~= '\\' and vim.loop.new_fs_event() or vim.loop.new_fs_poll(),
            master_commit_count = 0,
            unpushed_commit_count = 0,
            unpulled_commit_count = 0,
            update_master = function(self)
                local source = 'origin/' .. self.master_name
                if not self.origin_set then
                    -- fallback to compare with local branch
                    source = self.master_name
                end

                -- current branch may not be set yet
                if self.branch_name == '' or self.branch_name == self.master_name then
                    -- no need to display sync with master info in this case.
                    self.master_commit_count = -1
                    return
                end

                commitDiff(self.git_cwd, source, '^@', function(success, count)
                    if not success then
                        print("git log failed")
                        return
                    end

                    -- remove this if statement after implementing debounce on
                    -- fs watch
                    -- now, this function may return after figuring out the
                    -- current branch name
                    if not (self.branch_name == '' or self.branch_name == self.master_name) then
                        -- no need to display sync with master info in this case.
                        self.master_commit_count = count
                    end
                end)
            end,
            update_current = function(self)
                if not self.origin_set or self.no_upstream then
                    -- there is noting to compare with
                    return
                end

                commitDiff(self.git_cwd, '@', '^@{upstream}', function(success, count, err)
                    if not success then
                        if string.find(err, "no upstream configured") then
                            self.no_upstream = true
                            self.unpushed_commit_count = -1
                            return
                        end
                        print("git log failed")
                        return
                    end

                    self.unpushed_commit_count = count
                end)

                commitDiff(self.git_cwd, '^@', '@{upstream}', function(success, count, err)
                    if not success then
                        if string.find(err, "no upstream configured") then
                            self.no_upstream = true
                            self.unpulled_commit_count = -1
                            return
                        end
                        print("git log failed")
                        return
                    end

                    self.unpulled_commit_count = count
                end)
            end,
            sync_and_update_master = function(self)
                if not self.origin_set then
                    -- there is noting to sync with
                    -- just update, curent branch may be not master
                    self:update_master()
                    return
                end

                fetchBranch(self.git_cwd, self.master_name, function(success)
                    if not success then
                        print("failed to fetch branch " .. M.opts.master_name)
                        return
                    end
                    self:update_master()
                end)
            end,
            sync_and_update_current = function(self)
                if not self.origin_set then
                    -- there is noting to sync and compare with
                    return
                end

                fetchBranch(self.git_cwd, '@', function(success)
                    if not success then
                        print("failed to fetch branch @")
                        return
                    end
                    self:update_current()
                end)
            end,
        }
        git_repo_cache[git_dir] = git_repo

        local start_watch = function(repo)
            local init = function()
                M.watch_head(repo)
                M.watch_ref(repo)

                if repo.origin_set then
                    -- don't watch for changes in remote branch tip if there is
                    -- no origin.
                    M.watch_remote_ref(repo)
                end

                timer:start(0, M.opts.interval, vim.schedule_wrap(function()
                    print("tick: ", repo.dir)
                    if M.opts.diff_against_master then
                        repo:sync_and_update_master()
                    end
                    repo:sync_and_update_current()
                end))
            end

            checkOrigin(repo.git_cwd, function(success)
                if success then
                    repo.origin_set = true
                else
                    -- set special values, as zero (in sync) is misleading
                    repo.unpushed_commit_count = -1
                    repo.unpulled_commit_count = -1
                end

                if M.opts.findout_master_name and repo.origin_set then
                    getMasterName(repo.git_cwd, function(success, master_name)
                        if not success then
                            print("unable to get master name")
                            return
                        end
                        repo.maste_name = master_name
                        init()
                    end)
                    return
                end

                timer:start(0, M.opts.interval, vim.schedule_wrap(function()
                    init()
                end))
            end)
        end
        start_watch(git_repo)
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
    local file_dir
    if bufnr then
        local bufname = vim.fn.bufname(bufnr)
        file_dir = vim.fn.fnamemodify(bufname, ':p:h')
    else
        file_dir = vim.fn.expand('%:p:h')
    end

    local result = {}
    local git_dir = git_dir_cache[file_dir]
    if git_dir == nil then
        return result
    end

    local repo = git_repo_cache[git_dir]

    if M.opts.diff_against_master then
        table.insert(result, repo.master_commit_count)
    end
    table.insert(result, repo.unpulled_commit_count)
    table.insert(result, repo.unpushed_commit_count)
    return result
end

return M
