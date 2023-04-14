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
        master_name = self.options.master_name or 'master',
        findout_master_name = self.options.findout_master_name or true,
        diff_against_master = self.options.diff_against_master or false,
        interval = self.options.internval or 60000,
        unpulled_master_icon = self.options.unpulled_master_icon or '⇢ ',
        unpulled_icon = self.options.unpulled_icon or '⇣ ',
        unpushed_icon = self.options.unpushed_icon or '⇡ ',
        use_check_icon = self.options.use_check or true,
        check_icon = '󰸞',
    })
end

M.update_status = function(_, is_focused)
    local buf = (not is_focused and vim.api.nvim_get_current_buf())
    local status = modules.commits_status.status(buf)
    return modules.utils.stl_escape(status)
end

return M
