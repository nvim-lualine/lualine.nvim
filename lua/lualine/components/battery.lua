-- Copyright (c) 2023 Pheon-Dev
-- MIT license, see LICENSE for more details.
local lualine_require = require('lualine_require')
local M = lualine_require.require('lualine.component'):extend()

local default_options = {
  show_status_text = false,
  view = {
    charge = {
      zeros = { icon = "󰂎 " },
      tens = { icon = "󰁺 " },
      twenties = { icon = "󰁻 " },
      thirties = { icon = "󰁼 " },
      forties = { icon = "󰁽 " },
      fifties = { icon = "󰁾 " },
      sixties = { icon = "󰁿 " },
      seventies = { icon = "󰂀 " },
      eighties = { icon = "󰂁 " },
      nineties = { icon = "󰂂 " },
      hundred = { icon = "󰁹 " },
    },
    status = {
      enabled = true,
      charging = { icon = " 󱐋" },
      discharging = { icon = " 󱐌" },
      not_charging = { icon = "  " },
      full = { icon = "  " },
      unknown = { icon = " " },
      critical = { icon = " " },
      percentage = { icon = " 󰏰" },
    },
  },
}

function M:init(options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', self.options or {}, default_options)
end

function M:update_status()
  local cap, stat

  if vim.fn.executable("acpi") == 1 then
    cap = 'acpi -b | grep -Po "[0-9]+%" | awk -F "%" \'{ print $1 }\''
    stat = "acpi -b | awk -F \",\" '{ print $1 }' | awk -F \" \" '{ print $3 }'"
  elseif vim.fn.executable("pmset") == 1 then
    cap = 'pmset -g batt | grep -Eo "\\d+%"'
  else
    cap = "cat /sys/class/power_supply/BAT0/capacity"
    stat = "cat /sys/class/power_supply/BAT0/status"
  end

  function M.battery_status_job()
    local status_job_id = vim.fn.jobstart(stat, {
      on_stdout = function(_, data, _)
        local output = table.concat(data, "\n")

        if output and #output > 0 then
          output = output:gsub("%s+", "") -- Remove whitespace
          vim.g.battery_status = output
        end
      end,
      stdout_buffered = true,
    })

    vim.fn.jobwait({ status_job_id }, 0)
  end

  function M.battery_capacity_job()
    local capacity_job_id = vim.fn.jobstart(cap, {
      on_stdout = function(_, data, _)
        local output = table.concat(data, "\n")

        if output and #output > 0 then
          output = output:gsub("%s+", "") -- Remove whitespace
          vim.g.battery_capacity = output
        end
      end,
      stdout_buffered = true,
    })

    vim.fn.jobwait({ capacity_job_id }, 0)
  end

  M.battery_capacity_job()
  M.battery_status_job()
  local result = tostring(vim.g.battery_status)
  -- local capacity = tostring(vim.g.battery_capacity)
  -- local charge = tonumber(capacity)
  local icon = self.options.view.charge

  local icons = {
    icon.zeros.icon,
    icon.tens.icon,
    icon.twenties.icon,
    icon.thirties.icon,
    icon.forties.icon,
    icon.fifties.icon,
    icon.sixties.icon,
    icon.seventies.icon,
    icon.eighties.icon,
    icon.nineties.icon,
    icon.hundred.icon,
  }

  if result == "Charging" then
    return icons[os.date("%s") % #icons + 1]
  end
  -- if result == "Discharging" then
  --   if charge == 12 or charge == 15 or charge == 20 or charge == 7 or charge == 8 or charge == 9 or charge == 10 then
  --     print("Please plug in a charger, " .. charge .. "% remaining!")
  --   elseif charge <= 6 then
  --     vim.notify("Please plug in a charger, " .. charge .. "% remaining!")
  --   end
  -- end
  -- result = ""
--
--   if charge >= 0 and charge < 10 then
--     result = icon.zeros.icon
-- elseif charge >= 10 and charge < 20 then
--     result = icon.tens.icon
-- elseif charge >= 20 and charge < 30 then
--     result = icon.twenties.icon
--   elseif charge >= 30 and charge < 40 then
--     result = icon.thirties.icon
--   elseif charge >= 40 and charge < 50 then
--     result = icon.forties.icon
--   elseif charge >= 50 and charge < 60 then
--     result = icon.fifties.icon
--   elseif charge >= 60 and charge < 70 then
--     result = icon.sixties.icon
--   elseif charge >= 70 and charge < 80 then
--     result = icon.seventies.icon
--   elseif charge >= 80 and charge < 90 then
--     result = icon.eighties.icon
--   elseif charge >= 90 and charge < 100 then
--     result = icon.nineties.icon
--   elseif charge >= 100 then
--     result = icon.hundred.icon
--   end

  if result == "" then
    result = self.options.status.unknown.icon
  end

  local charge_value = tostring(vim.g.battery_capacity)
  result = result:gsub("\n", "")

  local status_result = vim.g.battery_status
  status_result = tostring(status_result)
  local status_res = ""

  local charge_icons = {
    self.options.view.status.charging.icon,
    self.options.view.status.discharging.icon,
  }

  if status_result == "Charging" then
    status_res = self.options.view.status.charging.icon
  elseif status_result == "Not" then
    status_res = self.options.view.status.not_charging.icon
  elseif status_result == "Full" then
    status_res = self.options.view.status.full.icon
  elseif status_result == "Discharging" then
    return charge_icons[os.date("%s") % #icons + 1]
  end
  if status_result == "" then
    status_res = self.options.view.status.unknown.icon
  end
  if self.options.show_status_text then
    status_res = status_result .. status_res
  end
  -- return result .. " " .. status_res

  return status_res .. " " .. result .. " " .. charge_value
end

return M
