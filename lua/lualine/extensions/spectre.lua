local _found, spectre = pcall(require, "spectre.state")
if not _found then
  vim.notify("spectre plugin not found", LOG.WARN)
  return
end

local function title() return "ಠ_ಠ Spectre" end
local function state()
  if spectre.status_line == "" or spectre.status_line == nil then
    return ""
  end

  return spectre.status_line
end

local M = {}

M.sections = {
  lualine_a = { title },
  lualine_b = { state }
}

M.filetypes = { "spectre_panel" }

return M
