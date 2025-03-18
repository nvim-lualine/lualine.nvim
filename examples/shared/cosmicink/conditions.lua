-- M table stores all the conditions for easier access
M = {}

-- Condition: Check if the buffer is not empty
-- This checks whether the current file's name is non-empty.
-- If the file is open (i.e., has a name), it returns true, meaning the buffer is not empty.
M.buffer_not_empty = function()
	return vim.fn.empty(vim.fn.expand('%:t')) ~= 1 -- 'expand('%:t')' gets the file name
end

-- Condition: Hide in width (only show the statusline when the window width is greater than 80)
-- This ensures that the statusline will only appear if the current window width exceeds 80 characters.
M.hide_in_width = function()
	return vim.fn.winwidth(0) > 80 -- 'winwidth(0)' returns the current window width
end

-- Condition: Check if the current workspace is inside a Git repository
-- This function checks if the current file is inside a Git repository by looking for a `.git` directory
-- in the current file's path. Returns true if the file is in a Git workspace.
M.check_git_workspace = function()
	local filepath = vim.fn.expand('%:p:h')               -- Get the current file's directory
	local gitdir = vim.fn.finddir('.git', filepath .. ';') -- Search for a `.git` directory in the file path
	return gitdir and #gitdir > 0 and #gitdir < #filepath -- Returns true if a `.git` directory is found
end

-- Return the conditions table to be used by other modules
return M

