local dynamicMode = require('lualine.dynamicMode')
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local entry_display = require "telescope.pickers.entry_display"

local M = {}



local function makeEntries()
  local modes = dynamicMode.registeredModes()
  table.sort(modes)
  local entries = {}
  local globalMode = dynamicMode.getMode('__GLOBAL__')
  for i, mode in ipairs(modes) do
    local hlGroup = globalMode == mode and 'TelescopeSelection' or 'TelescopeNormal'
    entries[i] = {mode=mode, hlGroup=hlGroup, index=i}
  end
  return entries
end

--- Generate a finder whose results are the current NeoWin terminals
local function getFinder()
  return finders.new_table {
    results = makeEntries(),
    entry_maker = function(entry)
      local widths = {{width=string.len(entry.mode)}}
      local displayer = entry_display.create {
        items = widths,
      }
      return {
        value = entry,
        display=function(e) 
          local displayArray = { {e.value.mode, e.value.hlGroup} }
          return displayer(displayArray)
        end,
        ordinal=entry.mode
      }
    end
  }
end


--- Telescope Action: toggle the selected lualine alt-mode
-- luacheck: push no unused args
local function toggleMode(prompt_bufnr)

  local entry = action_state.get_selected_entry()
  if entry == nil then return end
  local selectedMode = entry.value.mode

  local currentGlobal = dynamicMode.getMode('__GLOBAL__')
  local isOn = currentGlobal == selectedMode
  -- to turn off, set global mode to normal
  dynamicMode.setGlobalMode(isOn and 'normal' or selectedMode)
  currentGlobal = dynamicMode.getMode('__GLOBAL__')
  require('lualine').refresh({})
end
-- luacheck: pop



function M.lualinePick(opts, currentText, currentIndex, currentInputMode)
  opts = opts or {}
  currentText = currentText or ""
  currentIndex = currentIndex or 1
  currentInputMode = currentInputMode or 'normal'

  opts.dynamic_preview_title = true
  pickers.new(opts, {
    selection_strategy='reset',
    prompt_title = "Lualine Modes",
    sorter = conf.generic_sorter(opts),
    finder = getFinder(),
    default_text=currentText,
    default_selection_index=currentIndex,
    initial_mode=currentInputMode,
    -- luacheck: push no unused args
    attach_mappings = function(prompt_bufnr, map)
      -- map('<C-e>', 
      actions.select_default:replace(
        function() 
          toggleMode(prompt_bufnr)
          local currentPrompt = action_state.get_current_line()
          local currentIndex = action_state.get_selected_entry().value.index
          local inputMode = vim.fn.mode() == 'n' and 'normal' or 'insert'
          actions.close(prompt_bufnr)
          M.lualinePick(opts, currentPrompt, currentIndex, inputMode)
        end
      )
      return true
    end,
    -- luacheck: pop
  }):find()


end

return M
