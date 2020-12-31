local utils = require 'lualine.utils'

local function Branch()
  local branch

	local cb = function (err, data)
		if err == 0 and data then branch = data:match "^%*(.-)%s*$" end
	end

	utils.asyncCall('git', {'branch', '--show-current'}, cb)

  if not branch or #branch == 0 then
		utils.asyncCall('git', {'rev-parse', '--abbrev-ref', 'HEAD'}, cb)

		if not branch or #branch == 0 then return '' end
  end
  local ok,devicons = pcall(require,'nvim-web-devicons')
  if ok then
    local icon = devicons.get_icon('git')
    if icon ~= nil then
      return icon .. ' ' .. branch
    end
    return branch
  end
  ok = (vim.fn.exists('*WebDevIconsGetFileTypeSymbol'))
  if ok ~= 0 then
    local icon =  ''
    return icon .. ' ' .. branch
  end
  return branch
end

return Branch
