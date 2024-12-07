-- README:
-- Diffview buffers do not provide api for their info on the native winbar
-- These fn achieve a similar functionality

-- INFO: Functions and library to retrieve diffview info on buffers

local function in_git_repo()
  local handle = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null")
  if not handle then
    return false
  end
  local output = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return output == "true"
end

local function basename(path)
  return path:match("[^/]+$") or path
end

local function resolve_git_reference(ref)
  local handle = io.popen(string.format("git rev-parse --short %s 2>/dev/null", ref))
  if not handle then
    return nil
  end
  local resolved = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return resolved ~= "" and resolved or nil
end

local function get_relative_to_head(hash)
  local handle = io.popen(string.format("git rev-list --count %s..HEAD 2>/dev/null", hash))
  if not handle then
    return nil
  end
  local count = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return tonumber(count) and string.format("HEAD~%s", count) or hash
end

local function get_git_branch()
  local handle = io.popen("git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD")
  if not handle then
    return "HEAD"
  end
  local branch = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return branch ~= "" and branch or "HEAD"
end

-- Optional
-- local function is_remote_branch(ref)
--   local handle = io.popen(string.format("git branch -r --contains %s 2>/dev/null", ref))
--   if not handle then
--     return false
--   end
--   local remote = handle:read("*a"):match("%S+")
--   handle:close()
--   return remote and remote or false
-- end

local function get_all_branches_pointing_to(commit)
  local handle = io.popen(string.format("git branch -a --points-at %s 2>/dev/null", commit))
  if not handle then
    return {}
  end
  local output = handle:read("*a")
  handle:close()

  local branches = {}
  for line in output:gmatch("[^\r\n]+") do
    -- Remove leading '*', spaces, etc.
    line = line:gsub("^%*", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if line ~= "" then
      table.insert(branches, line)
    end
  end
  return branches
end

local function get_tag_for_commit(hash)
  local handle = io.popen(string.format("git tag --points-at %s 2>/dev/null", hash))
  if not handle then
    return nil
  end
  local tag = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return tag ~= "" and tag or nil
end

local function get_diffview_buffer_info(commit, filename, show_filename)
  local inside_repo = in_git_repo()
  local base = basename(filename)

  -- If no commit given:
  if not commit or commit == "" then
    if inside_repo then
      if show_filename then
        return "WORKING TREE " .. base
      else
        return "WORKING TREE"
      end
    else
      return base
    end
  end

  -- print('DEBUG: commit: ' .. commit .. ' , filename: ', filename)
  -- Handle .git/-style commit references (index/stages)
  if commit:match("^%.git") then
    -- Check if filename starts with :0, :1, :2, or :3
    -- Pattern: :<stage>[:optional/path/to/file]
    -- local stage, rest = filename:match("^:(%d+)(:(.*))?$")
    local stage, rest = filename:match("^:(%d+):?(.*)$")
    if stage then
      stage = tonumber(stage)
      local label
      if stage == 0 then
        label = "INDEX"
      elseif stage == 1 then
        label = "Base"
      elseif stage == 2 then
        label = "OURS"
      elseif stage == 3 then
        label = "THEIRS"
      end

      if show_filename and rest and rest ~= "" then
        -- rest is the path after the stage, show basename of that path
        local rest_base = basename(rest)
        return label .. " " .. rest_base
      else
        -- no further path, just show the label
        return label
      end
    else
      -- If no stage detected, just show the filename as is
      -- Or you could return something else if desired.
      return inside_repo and ("WORKING TREE " .. base) or base
    end
  end

  -- If we have a normal commit reference:
  local short = resolve_git_reference(commit)
  if not short then
    -- Couldn't resolve commit, fallback
    if inside_repo then
      return "ERROR (No Short) for commit " .. commit .. base
    else
      return base
    end
  end


  local head_short = resolve_git_reference("HEAD")
  local branch = get_git_branch()
  local branch_short = resolve_git_reference(branch)

  -- Collect all possible matches
  local matches = {}

  -- If commit is HEAD
  if short == head_short then
    table.insert(matches, "HEAD")
  end

  -- If commit matches the current local branch
  if branch_short and short == branch_short then
    table.insert(matches, branch)
  end

  -- All branches (including remote) pointing exactly to this commit
  local pointing_branches = get_all_branches_pointing_to(short)
  for _, br in ipairs(pointing_branches) do
    local already_in = false
    for _, m in ipairs(matches) do
      if m == br then
        already_in = true
        break
      end
    end
    if not already_in then
      table.insert(matches, br)
    end
  end

  -- HEAD~N format
  local relative = get_relative_to_head(short)
  if relative and relative ~= short then
    table.insert(matches, relative)
  end

  -- If there's a tag
  local tag = get_tag_for_commit(short)
  if tag then
    table.insert(matches, tag)
  end

  -- If we found no special references, just use the short commit hash
  -- if #matches == 0 then
  table.insert(matches, short)
  -- end

  -- Format matches {ref} {ref2} ...
  local formatted = {}
  for _, m in ipairs(matches) do
    formatted[#formatted+1] = "{" .. m .. "}"
  end

  local result = table.concat(formatted, " ")
  if show_filename and base and base ~= "" then
    result = result .. ": " .. base
  end

  return result
end


local function parse_diffview_buffer_name(bufname)
  local git_part = bufname:match("%.git/(.*)$")
  if git_part then
    -- Check for staging syntax like :0, :1, :2, :3
    -- local stage, rest = git_part:match("^:(%d+)(:(.*))?$")
    local stage, rest = git_part:match("^:(%d+):?(.*)$")
    if stage then
      -- This is a staged scenario, commit = ".git"
      -- rest is optional path after :N
      -- INFO: Avoiding rest
      if rest and rest ~= "" then
        return ".git", ":"..stage..":"..rest
      else
        return ".git", ":"..stage
      end
    end

    -- Otherwise, try to parse a commit (assuming anything up to next slash is commit)
    local commit, path_after = git_part:match("^([^/]+)/(.+)$")
    if commit and path_after then
      return commit, path_after
    elseif commit then
      -- commit but no further path
      return commit, commit
    else
      -- .git present but no recognizable commit or stage pattern
      -- Just treat the remainder as filename
      return nil, basename(bufname)
    end
  else
    -- No .git in the name, no commit
    return nil, basename(bufname)
  end
end

-- INFO: lualine extension definition

local M = {}

-- INFO add filename to the returned string
M.show_filename = false
-- The function that derives commit and filename from the active buffer:
M.get_current_diffview_buffer_info = function()
  local bufname = vim.api.nvim_buf_get_name(0) -- current buffer's name
  local commit, filename = parse_diffview_buffer_name(bufname)
  if not commit then
    -- no commit found, treat entire bufname as filename
    filename = bufname
    commit = nil
  end
  return get_diffview_buffer_info(commit, filename, M.show_filename)
end

M.winbar = {
  lualine_a = {
    {
      'filename',
    },
  },
  lualine_b = {
    {M.get_current_diffview_buffer_info, },
  },
}
M.inactive_winbar = {
  lualine_a = {
    {
      'filename',
    },
  },
  lualine_b = {
    {M.get_current_diffview_buffer_info, },
  },
}

-- Restrict to Diffview buffers
-- M.buftypes = {''}
M.filetypes = {
  --Null
  'null',

  -- Programming Languages
  'lua', 'python', 'javascript', 'typescript', 'html', 'css', 'json', 'yaml', 'yml',
  'markdown', 'md', 'c', 'cpp', 'cxx', 'h', 'hpp', 'java', 'ruby', 'go', 'php', 'rust',
  'sh', 'bash', 'vim', 'toml',

  -- Configuration & Build Files
  'gitcommit', 'gitrebase', 'make', 'dockerfile', 'env', 'ini', 'conf',

  -- Markup and Documentation
  'xml', 'tex', 'latex', 'asciidoc', 'rst',

  -- Plugin/Framework Specific
  'NvimTree', 'dashboard', 'packer', 'quickfix', 'help', 'terminal', 'diff', 'TelescopePrompt',
}

return M
