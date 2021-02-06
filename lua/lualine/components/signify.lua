local async = require('lualine.async')

-- variable to store git diff stats
local git_diff = nil

-- process diff data and update git_diff{ added, removed, modified}
local function process_diff(data)
  -- Adapted from https://github.com/wbthomason/nvim-vcs.lua
  local added, removed, modified = 0, 0, 0
  for line in vim.gsplit(data, '\n') do
    if string.find(line, [[^@@ ]]) then
      local tokens = vim.fn.matchlist(line, [[^@@ -\v(\d+),?(\d*) \+(\d+),?(\d*)]])
      local line_stats = {
        mod_count = tokens[3] == '' and 1 or tonumber(tokens[3]),
        new_count = tokens[5] == '' and 1 or tonumber(tokens[5])
      }

      if line_stats.mod_count == 0 and line_stats.new_count > 0 then
        added = added + line_stats.new_count
      elseif line_stats.mod_count > 0 and line_stats.new_count == 0 then
        removed = removed + line_stats.mod_count
      else
        modified = modified + line_stats.mod_count
      end
    end
  end
  git_diff = { added,  removed, modified }
end

-- variable to store git_diff getter async function
local get_git_diff = nil
-- flag to see if async job exited before updating git_diff
local updated = false

-- Updates the async function for current file
local function update_git_diff_getter()
  -- stop older function properly before overwritting it
  if get_git_diff then get_git_diff:stop() end
  -- Donn't show git diff when current buffer doesn't have a filename
  if #vim.fn.expand('%') == 0 then get_git_diff = nil; return end
  get_git_diff = async:new({
    cmd = string.format([[git -C %s --no-pager diff --no-color --no-ext-diff -U0 -- %s]]
    ,vim.fn.expand('%:h'), vim.fn.expand('%:t')),
    on_stdout = function(_, data)
      if data then
        process_diff(data)
        updated = true
      end
    end,
    on_stderr = function (_, data)
      if data then
        git_diff = nil
        updated = true
      end
    end,
    on_exit = function()
      if not updated then
        -- updated not set means git exited without emmiting anything on stdout
        -- or stderr means file is unchanged
        git_diff = {0, 0, 0}
      end
    end
  })
end

-- Update git_diff veriable
local function update_git_diff()
  vim.schedule_wrap(function()
    if get_git_diff then
      updated = false
      get_git_diff:start()
    end
  end)()
end

_G.lualine_update_git_diff = update_git_diff
_G.lualine_update_git_diff_getter = update_git_diff_getter

vim.api.nvim_exec([[
  autocmd lualine BufEnter     * call v:lua.lualine_update_git_diff_getter()
  autocmd lualine BufEnter     * call v:lua.lualine_update_git_diff()
  autocmd lualine BufWritePost * call v:lua.lualine_update_git_diff()
  ]], false)

local function signify()
   if git_diff == nil then return '' end
   local symbols = {
     '+',
     '-',
     '~',
   }
   local result = {}
   for range=1,3 do
     if git_diff[range] ~= nil and git_diff[range] > 0
       then table.insert(result,symbols[range]..''..git_diff[range])
     end
   end

   if result[1] ~= nil then
       return table.concat(result, ' ')
   else
       return ''
   end
end


return signify
