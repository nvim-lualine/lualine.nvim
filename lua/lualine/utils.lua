local M = {  }

local uv = vim.loop

function M.asyncCall (cmd, args, cb)
	local handle
	local stdout, stderr = uv.new_pipe(false)

	local function onread(err, data)
		cb(err, data)
	end

	handle = uv.spawn(cmd, {
		args=args,
		cwd=vim.fn.expand('%:p:h:S')
	},
	vim.schedule_wrap(function(response_code)
		-- do error handling here if response_code ~= 0
		stdout:read_stop()
		stderr:read_stop()

		stdout:close()
		stderr:close()
		handle:close()
	end)
	)

	uv.read_start(stdout, onread)
	uv.read_start(stderr, onread)
end

function M.setTheme(theme)
  return require('lualine.themes.'..theme)
end

function M.drawSection(section, separator)
  local status = ''
  for index, statusFunction in pairs(section) do
    local localstatus = statusFunction()
    if localstatus:len() > 0 then
      if separator:len() > 0 then
        if index > 1 then
          status = status .. separator .. ' '
        end
        status = status .. localstatus
        status = status .. ' '
      else
        status = status .. localstatus
        status = status .. ' '
      end
    end
  end
  if status:len() > 0 then
    if separator:len() > 0 and table.maxn(section) > 1 then
      return ' ' .. status .. ' '
    end
    return ' ' .. status
  end
  return ''
end

return M
