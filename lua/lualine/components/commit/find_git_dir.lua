-- os specific path separator
local sep = package.config:sub(1, 1)

local M = {}

local git_dir_cache = {} -- Stores git paths that we already know of, map file dir to git_dir

-- function taken from ../branch/git_branch.lua module. Code was adjusted to
-- remove setting current_git_dir global variable and remove update_branch()
-- call (component specific).
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

return M
