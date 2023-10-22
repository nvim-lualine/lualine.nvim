local M = require('lualine.component'):extend()
local modules = require('lualine_require').lazy_require {
  status = 'lualine.components.commit.status',
  utils = 'lualine.utils.utils',
}

local default_options = {
  icon = '',
  master_name = 'master',
  colored = true,
  findout_master_name = false,
  diff_against_master = false,
  fetch_interval = 60000,
  unpulled_master_icon = '⇢ ',
  unpulled_icon = '⇣ ',
  unpushed_icon = '⇡ ',
  use_check_icon = true,
  check_icon = '󰸞',
  show_only_diverged = true,
}

local function apply_default_colors(opts)
  local default_color = {
    insync = {
      fg = modules.utils.extract_color_from_hllist('fg', { 'lualine_a_inactive' }, '#90ee90'),
    },
    diverged = {
      fg = modules.utils.extract_color_from_hllist(
        'fg',
        { 'GitSignsChange', 'GitGutterChange', 'DiffChanged', 'DiffChange' },
        '#f0e130'
      ),
    },
    conflict = {
      fg = modules.utils.extract_color_from_hllist(
        'fg',
        { 'GitSignsDelete', 'GitGutterDelete', 'DiffRemoved', 'DiffDelete' },
        '#ff0038'
      ),
    },
  }
  opts.color = vim.tbl_deep_extend('keep', opts.color or {}, default_color)
end

-- Initializer
M.init = function(self, options)
  M.super.init(self, options)
  apply_default_colors(self.options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)

  if self.options.colored then
    self.highlights = {
      insync = self:create_hl(self.options.color.insync, 'insync'),
      diverged = self:create_hl(self.options.color.diverged, 'diverged'),
      conflict = self:create_hl(self.options.color.conflict, 'conflict'),
    }
  end

  modules.status.init {
    master_name = self.options.master_name,
    findout_master_name = self.options.findout_master_name,
    diff_against_master = self.options.diff_against_master,
    fetch_interval = self.options.fetch_interval,
  }
end

function M:update_status(_, is_focused)
  local buf = (not is_focused and vim.api.nvim_get_current_buf())

  local colors = {}
  if self.options.colored then
    -- load the highlights and store them in colors table
    for name, highlight_name in pairs(self.highlights) do
      colors[name] = self:format_hl(highlight_name)
    end
  end

  local status = modules.status.status(buf)
  local result = {}
  local icons = {
    self.options.unpulled_master_icon,
    self.options.unpulled_icon,
    self.options.unpushed_icon,
  }

  if not self.options.diff_against_master then
    table.remove(status, 1)
  end

  for k, v in ipairs(status) do
    local has_conflict = table.remove(v)
    for k2, d in ipairs(v) do
      if not (self.options.show_only_diverged and d == 0) and d ~= -1 then
        local count = tostring(d)
        if self.options.use_check_icon then
          if d == 0 then
            count = self.options.check_icon
          end
        end

        local icon_pos
        if not self.options.diff_against_master then
          icon_pos = k2 + 1
        else
          if k == 1 then
            icon_pos = 1
          else
            icon_pos = k2 + 1
          end
        end

        local icon = icons[icon_pos]
        if self.options.colored then
          local color = (d > 0) and colors['diverged'] or colors['insync']
          if has_conflict then
            color = colors['conflict']
          end

          table.insert(result, color .. icon .. count .. (has_conflict and '!' or ''))
        else
          table.insert(result, icon .. count .. (has_conflict and '!' or ''))
        end
      end
    end
  end

  return table.concat(result, ' ')
end

return M
