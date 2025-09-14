local dynamicMode = require('lualine.dynamicMode')
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local previewers = require'telescope.previewers'
local action_state = require "telescope.actions.state"
local api = vim.api

local M = {}


--- Generate a finder whose results are the current NeoWin terminals 
local function getFinder()
  return finders.new_table {
    results = dynamicMode.allModes(),
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
local function selectMode(prompt_bufnr)
  local selectedMode = action_state.get_selected_entry().value
  local isOn = dynamicMode.currentMode('__GLOBAL__') == selectedMode
  dynamicMode.setGlobal(selectedMode, not isOn)
end



function M.lualinePick(opts)
  opts = opts or {}
  opts.dynamic_preview_title = true
  pickers.new(opts, {
    prompt_title = "Lualine Modes",
    sorter = conf.generic_sorter(opts),
    finder = getFinder(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(selectMode)
      return true
    end,
}):find()
end

return M
