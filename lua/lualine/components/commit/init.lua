local M = require('lualine.component'):extend()
local modules = require('lualine_require').lazy_require {
    commits_status = 'lualine.components.commit.commits_status',
    utils = 'lualine.utils.utils',
}

-- Initializer
M.init = function(self, options)
    M.super.init(self, options)
    if not self.options.icon then
        self.options.icon = ''
    end

    modules.commits_status.init({
        interval = self.options.internval or 10000,
        unpulled_master_icon = self.options.unpulled_master_icon or '⇢ ',
        unpulled_icon = self.options.unpulled_icon or '⇣ ',
        unpushed_icon = self.options.unpushed_icon or '⇡ ',
    })
end

M.update_status = function(_, is_focused)
    local buf = (not is_focused and vim.api.nvim_get_current_buf())
    local status = modules.commits_status.status(buf)
    return modules.utils.stl_escape(status)
end

return M
