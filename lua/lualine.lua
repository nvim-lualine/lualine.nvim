local utils = require('lualine.utils')
local highlight = require('lualine.highlight')

local M = { }

M.theme = 'gruvbox'
local theme_set = {}

M.component_separators = {'', ''}
M.section_separators = {'', ''}


M.sections = {
  lualine_a = { 'mode' },
  lualine_b = { 'branch' },
  lualine_c = { 'filename' },
  lualine_x = { 'encoding', 'fileformat', 'filetype' },
  lualine_y = { 'progress' },
  lualine_z = { 'location'  },
}

M.inactive_sections = {
  lualine_a = {  },
  lualine_b = {  },
  lualine_c = { 'filename' },
  lualine_x = { 'location' },
  lualine_y = {  },
  lualine_z = {  }
}

M.extensions = {
}

local function load_components()
  local function load_sections(sections)
    for _, section in pairs(sections) do
      for index, component in pairs(section) do
        if type(component) == 'string' then
          section[index] = require('lualine.components.' .. component)
        end
      end
    end
  end
  load_sections(M.sections)
  load_sections(M.inactive_sections)
end

local function  load_extensions()
  for _, extension in pairs(M.extensions) do
    if type(extension) == 'string' then
      require('lualine.extensions.' .. extension).load_extension()
    end
    if type(extension) == 'table' then
      extension.load_extension()
    end
    if type(extension) == 'function' then
      extension()
    end
  end
end

local function set_lualine_theme()
  if type(M.theme) == 'string' then
    M.theme = require('lualine.themes.'.. M.theme)
  end
  highlight.create_highlight_groups(M.theme)
  theme_set = M.theme
end

local function statusline(sections, is_focused)
  -- status_builder stores statusline without section_separators
  local status_builder = {}
  -- The sequence sections should maintain
  local section_sequence = {'a', 'b', 'c', 'x', 'y', 'z'}
  -- section -> highlight_group map
  local highlight_lookup_map = {a = 'a', b = 'b', c = 'c',
                                x = 'c', y = 'b', z = 'a'}

  for _, sec in ipairs(section_sequence) do
    if sections['lualine_'..sec] then
      -- temporary storage to store highlight+components
      -- before loading to status_builder
      local tmp_section = {}
      local separator = sec < 'x' and M.component_separators[1]
                                  or M.component_separators[2]
      table.insert(tmp_section, highlight.format_highlight(is_focused,
                   'lualine_'..highlight_lookup_map[sec]))
      table.insert(tmp_section, utils.draw_section(sections['lualine_'..sec],
                   separator))
      -- insert highlight+components of this section to
      -- status_builder indexed by section name
      table.insert(status_builder, {sec, table.concat(tmp_section,'')})
    end
  end
  
  -- Actual statusline
  local status = {}
  local half_passed = false
  for i=1,#status_builder do
    -- provide section_separators when statusline is in focus
    if is_focused then
      -- component separator needs to have fg of current_section
      -- and bg of adjacent section
      local prev_section = status_builder[i-1] and status_builder[i-1][1]
      local cur_section = status_builder[i][1]
      local next_section = status_builder[i+1] and status_builder[i+1][1]

      -- add half section separator before x
      if not half_passed and cur_section > 'c' then
        -- Just making sure highlight is set to section c .
        table.insert(status, highlight.format_highlight(is_focused, 'lualine_c'))
        table.insert(status, "%=")
        half_passed = true
      end

      -- For 2nd half we need to show separator before section
      if cur_section > 'x' then
        -- nextline is required when none of a,b,c are specified
        -- We will just use c sections background for rest of the statusline
        -- So we need to draw separators acordingly
        -- If have just passed the half set the prev section highlight to c
        -- As before adding %= highlight will be set to c
        if not prev_section or prev_section < 'x' then
          prev_section = 'c' end
        table.insert(status, highlight.format_highlight(is_focused,
                     'lualine_'..highlight_lookup_map[cur_section]..
                     '_'..highlight_lookup_map[prev_section]))
        table.insert(status, M.section_separators[2])
      end

      -- **( insert the actual section in the middle )** --
      table.insert(status, status_builder[i][2])

      -- For 1st half we need to show separator after section
      if cur_section < 'c' then
        -- nextline is required when none of x,y,z are specified
        -- We will just use c sections background for rest of the statusline
        -- this portion is only executed for a and b section so > c means x/y/z
        if not next_section or next_section > 'c' then
          next_section = 'c' end
        table.insert(status, highlight.format_highlight(is_focused,
                     'lualine_'..highlight_lookup_map[cur_section]..
                     '_'..highlight_lookup_map[next_section]))
        table.insert(status, M.section_separators[1])
      end
    else -- when not in focus
      if not half_passed and status_builder[i][1] > 'c' then
        table.insert(status, "%=")
        half_passed = true
      end
      table.insert(status, status_builder[i][2])
    end
  end
  -- incase none of x,y,z was configured lets not fill whole statusline with a,b,c section
  if not half_passed then
    table.insert(status, highlight.format_highlight(is_focused,'lualine_c').."%=") end
  return table.concat(status)
end

local function status_dispatch()
  if vim.g.statusline_winid == vim.fn.win_getid() then
    return statusline(M.sections, true)
  else
    return statusline(M.inactive_sections, false)
  end
end

local function exec_autocommands()
  _G.set_lualine_theme = set_lualine_theme
  vim.api.nvim_exec([[
    augroup lualine
    autocmd!
    autocmd ColorScheme * call v:lua.set_lualine_theme()
    augroup END
  ]], false)
end

function M.status()
  load_components()
  load_extensions()
  set_lualine_theme()
  exec_autocommands()
  _G.lualine_statusline = status_dispatch
  vim.o.statusline = '%!v:lua.lualine_statusline()'
end

return M
