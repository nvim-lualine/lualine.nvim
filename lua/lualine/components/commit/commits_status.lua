local M = {}

local os = require('os')
local require = require('lualine_require').require
local utils = require('lualine.utils.utils')

local current_git_dir = ''
-- os specific path separator
local sep = package.config:sub(1, 1)

local git_dir_cache = {}  -- Stores git paths that we already know of, map file dir to git_dir
local git_repo_cache = {} -- Stores information about git repository commits

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
            timer:start(0, 10000, function()
                local time = os.date("*t")
            end)
        end
        start_timer(git_repo)
        return
    end

    -- restart timer
    git_repo.timer:again()
end

function M.init()
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
        return 'not a git dir'
    end

    local repo = git_repo_cache[git_dir]

    return '⇢ ' ..
        tostring(repo.master_commit_count) ..
        ' ⇣ ' .. tostring(repo.unpulled_commit_count) .. ' ⇡ ' .. tostring(repo.unpushed_commit_count)
end

return M
