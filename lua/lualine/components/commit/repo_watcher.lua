local require = require('lualine_require').require
local jobs = require('lualine.components.commit.jobs')
local git_dir = require('lualine.components.commit.find_git_dir')
local find_git_dir = git_dir.find_git_dir

-- os specific path separator
local sep = package.config:sub(1, 1)
local fs_watch_flags = sep ~= '\\' and {} or 1000

---Validates args for `throttle()` and  `debounce()`.
local function td_validate(fn, ms)
    vim.validate {
        fn = { fn, 'f' },
        ms = {
            ms,
            function(ms)
                return type(ms) == 'number' and ms > 0
            end,
            "number > 0",
        },
    }
end

--- Throttles a function on the trailing edge. Automatically
--- `schedule_wrap()`s.
---
--@param fn (function) Function to throttle
--@param timeout (number) Timeout in ms
--@param last (boolean, optional) Whether to use the arguments of the last
---call to `fn` within the timeframe. Default: Use arguments of the first call.
--@returns (function, timer) Throttled function and timer. Remember to call
---`timer:close()` at the end or you will leak memory!
function throttle_trailing(fn, ms, last)
    td_validate(fn, ms)
    local timer = vim.loop.new_timer()
    local running = false

    local wrapped_fn
    if not last then
        function wrapped_fn(...)
            if not running then
                local argv = { ... }
                local argc = select('#', ...)

                timer:start(ms, 0, function()
                    running = false
                    pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
                end)
                running = true
            end
        end
    else
        local argv, argc
        function wrapped_fn(...)
            argv = { ... }
            argc = select('#', ...)

            if not running then
                timer:start(ms, 0, function()
                    running = false
                    pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
                end)
                running = true
            end
        end
    end
    return wrapped_fn, timer
end

local RepoWatcher = {}

local default_options = {
    master_name = 'master',
    fetch_interval = 60000,
    diff_against_master = false,
    findout_master_name = false,
}

function RepoWatcher:new(git_dir, options)
    local o = vim.tbl_deep_extend('keep', options or {}, default_options)
    local timer = vim.loop.new_timer()

    local fs_event = function()
        return sep ~= '\\' and vim.loop.new_fs_event() or vim.loop.new_fs_poll()
    end

    local repo = vim.tbl_deep_extend('force', o, {
        dir = git_dir,
        git_cwd = vim.fs.dirname(git_dir),
        ref = '',
        branch_name = '',
        origin_set = false,
        no_upstream = false,
        timer = timer,
        head_changed = fs_event(),
        branch_tip_changed = fs_event(),
        remote_branch_tip_changed = fs_event(),
        master_commit_count = 0,
        unpushed_commit_count = 0,
        unpulled_commit_count = 0,
        current_branch_conflict = false,
        master_branch_conflict = false,
        update = throttle_trailing(function(self)
            if self.diff_against_master then
                self:_update_master()
            end
            self:_update_current()
        end, 50, false)
    })

    setmetatable(repo, self)
    self.__index = self

    repo:start_watch()
    return repo
end

function RepoWatcher:start_watch()
    local init = function()
        self:watch_head()
        self:watch_ref()

        if self.origin_set then
            -- don't watch for changes in remote branch tip if there is
            -- no origin.
            self:watch_remote_ref()
        end

        self.timer:start(0, self.fetch_interval, vim.schedule_wrap(function()
            if self.diff_against_master then
                self:sync_master()
            end
            self:sync_current()
        end))
    end

    jobs.check_origin(self.git_cwd, function(success)
        if success then
            self.origin_set = true
        else
            -- set special values, as zero (in sync) is misleading
            self.unpushed_commit_count = -1
            self.unpulled_commit_count = -1
        end

        if self.findout_master_name and self.origin_set then
            jobs.get_master_name(self.git_cwd, function(success, master_name)
                if not success then
                    print("unable to get master name")
                    return
                end
                self.maste_name = master_name
                init()
            end)
            return
        end

        init()
    end)
end

-- watch_head starts filesystem watch on changes to the .git/HEAD file. Enables
-- detection of branch change outside of the editor.
function RepoWatcher:watch_head()
    self.head_changed:stop()

    self:update()

    -- Get HEAD branch name
    local head_file = self.dir .. sep .. 'HEAD'
    local lines = {}
    for line in io.lines(head_file) do
        lines[#lines + 1] = line
    end
    local ref = lines[1]:gsub("ref: ", "")
    local branch_name = ref:gsub("refs/heads/", "")

    if ref ~= self.ref then
        self.ref = ref
        self.branch_name = branch_name
        -- Reset the no_upstream flag, as we don't know yet.
        -- The check is done at the first diff attempt.
        self.no_upstream = false
        -- Reset ref and remote ref file watchers
        self:watch_ref()
        if self.origin_set then
            self:watch_remote_ref()
        end
    end

    self.head_changed:start(
        head_file,
        fs_watch_flags,
        vim.schedule_wrap(function()
            self:watch_head()
        end)
    )
end

-- watch_ref starts filesystem watch on changes to the `self.ref`. Enables
-- detection of branch head change, ex. new commits, moving head to different commit
-- etc.
function RepoWatcher:watch_ref()
    self.branch_tip_changed:stop()
    self:update()

    local branch_tip_file = self.dir .. sep .. self.ref
    self.branch_tip_changed:start(
        branch_tip_file,
        fs_watch_flags,
        vim.schedule_wrap(function()
            self:watch_ref()
        end)
    )
end

-- watch_remote_ref starts filesystem watch on changes to the remote `self.ref`.
-- Enables detection of new commits in the ref's remote usually through `git
-- fetch`.
function RepoWatcher:watch_remote_ref()
    self.remote_branch_tip_changed:stop()

    self:update()

    local remote_branch_tip_file = self.dir .. sep .. self.ref:gsub("heads", "remotes/origin")
    self.remote_branch_tip_changed:start(
        remote_branch_tip_file,
        fs_watch_flags,
        vim.schedule_wrap(function()
            self.watch_remote_ref()
        end)
    )
end

function RepoWatcher:restart_watch()
    self.timer:again()
end

function RepoWatcher:_update_master()
    local source = 'origin/' .. self.master_name
    if not self.origin_set then
        -- fallback to compare with local branch
        source = self.master_name
    end

    -- current branch may not be set yet
    if self.branch_name == '' or self.branch_name == self.master_name then
        -- no need to display sync with master info in this case.
        self.master_commit_count = -1
        self.master_branch_conflict = false
        return
    end

    jobs.commit_diff(self.git_cwd, source, '^@', function(success, count)
        if not success then
            print("git log failed")
            return
        end
        self.master_commit_count = count
    end)

    if self.origin_set then
        jobs.check_for_conflict(self.git_cwd, source, '@', function(success, has_conflict)
            if not success then
                print("failed to check for conflict")
                return
            end
            self.master_branch_conflict = has_conflict
        end)
    end
end

function RepoWatcher:_update_current()
    if not self.origin_set or self.no_upstream then
        -- there is noting to compare with
        return
    end

    jobs.commit_diff(self.git_cwd, '@', '^@{upstream}', function(success, count, err)
        if not success then
            if string.find(err, "no upstream configured") then
                self.no_upstream = true
                self.unpushed_commit_count = -1
                self.current_branch_conflict = false
                return
            end
            print("git log failed")
            return
        end

        self.unpushed_commit_count = count
    end)

    jobs.commit_diff(self.git_cwd, '^@', '@{upstream}', function(success, count, err)
        if not success then
            if string.find(err, "no upstream configured") then
                self.no_upstream = true
                self.unpulled_commit_count = -1
                self.current_branch_conflict = false
                return
            end
            print("git log failed")
            return
        end

        self.unpulled_commit_count = count
    end)

    jobs.check_for_conflict(self.git_cwd, '@{upstream}', '@', function(success, has_conflict)
        if not success then
            print("failed to check for conflict on current branch")
            return
        end
        self.current_branch_conflict = has_conflict
    end)
end

function RepoWatcher:sync_master()
    if not self.origin_set then
        -- there is noting to sync with
        -- just update, current branch may not be master
        -- we would like to compare local master with local branch
        self:update()
        return
    end

    jobs.fetch_branch(self.git_cwd, self.master_name, function(success)
        if not success then
            print("failed to fetch branch " .. self.master_name)
            return
        end
        self:update()
    end)
end

function RepoWatcher:sync_current()
    if not self.origin_set then
        -- there is noting to sync and compare with
        return
    end

    jobs.fetch_branch(self.git_cwd, '@', function(success)
        if not success then
            print("failed to fetch branch @")
            return
        end
        self:update()
    end)
end

return { RepoWatcher = RepoWatcher }
