-- MIT license, see LICENSE for more details.
-- extension for CopilotC-Nvim/CopilotChat.nvim

local M = {}

local function get_copilotchat_model_name()
  local ok, cc_config = pcall(require, 'CopilotChat.config')
  if ok and type(cc_config.model) == "string" and cc_config.model then
    return cc_config.model
  else
    vim.notify("CopilotChat model name unavailable", vim.log.levels.WARN)
    return "LLM: N/A"
  end
end

M.sections = {
  lualine_a = { 'filetype' },
  lualine_b = { get_copilotchat_model_name },
  lualine_z = { 'mode' }
}

M.filetypes = { 'copilot-chat' }

return M
