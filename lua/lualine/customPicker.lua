local dynamicMode = require('lualine.dynamicMode')
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}


--- Generate a finder whose results are the current NeoWin terminals
local function getFinder()
  return finders.new_table {
    results = dynamicMode.registeredModes(),
    entry_maker = function(entry)
      return {
        value = entry,
        display = entry,
        ordinal=entry
      }
    end
  }
end


--- Telescope Action: toggle the selected lualine alt-mode
-- luacheck: push no unused args
local function selectMode(_)
  local selectedMode = action_state.get_selected_entry().value
  local isOn = dynamicMode.getMode('__GLOBAL__') == selectedMode
  dynamicMode.setGlobalMode(selectedMode, not isOn)
end
-- luacheck: pop



function M.lualinePick(opts)
  opts = opts or {}
  opts.dynamic_preview_title = true
  pickers.new(opts, {
    prompt_title = "Lualine Modes",
    sorter = conf.generic_sorter(opts),
    finder = getFinder(),
    -- luacheck: push no unused args
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(selectMode)
      return true
    end,
    -- luacheck: pop
}):find()
end

return M
