-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.
local M = require('lualine.component'):extend()

-- stylua: ignore
local symbols = {
  unix = '', -- e712
  dos = '', -- e70f
  mac = '', -- e711
}

-- stylua: ignore
local distro = {
  bsd = '',
  Arch = '',
  Gentoo = '',
  Ubuntu = '',
  Cent = '',
  Debian = '',
  openSUSE = '',
  Dock = '',
}

-- Initializer
function M:init(options)
  -- Run super()
  M.super.init(self, options)
  -- Apply default symbols
  self.symbols = vim.tbl_extend('keep', self.options.symbols or {}, symbols)
  self.distro = distro
end

-- Function that runs every time statusline is updated
function M:update_status()
  local format = vim.bo.fileformat
  if self.options.icons_enabled then
    return self:get_os_logo(format) or format
  else
    return format
  end
end

function M:is_darwin()
  local fd = io.popen('uname -s')
  if not fd then
    return false
  end

  local os_name = fd:read('*a')
  fd:close()

  if vim.split(os_name, '\n')[1] == 'Darwin' then
    return true
  end
end

function M:get_distro()
  if vim.fn.executable('lsb_release') then
    local fd = io.popen('lsb_release -i')

    if not fd then
      return self.symbols['unix']
    end

    local lsb = fd:read('*a')
    local os_name = vim.split(lsb, '\t')[2]
    os_name = vim.split(os_name, '\n')[1]
    --vim.api.nvim_echo({ { vim.inspect(os_name) } }, true, {})
    if self.distro[os_name] == nil then
      return self.symbols['unix']
    end
    return self.distro[os_name]
  end
end

function M:get_os_logo(format)
  if format == 'dos' then
    return self.symbols['dos']
  elseif format == 'unix' then
    if self:is_darwin() then
      return self.symbols['mac']
    else
      return self:get_distro()
    end
  elseif format == 'mac' then
    return self.symbols['mac']
  end
end

return M
