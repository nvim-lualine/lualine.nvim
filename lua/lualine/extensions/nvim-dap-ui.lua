local M = {}

M.filetypes = {
    "dap-repl",
    "dapui_console",
    "dapui_console",
    "dapui_watches",
    "dapui_stacks",
    "dapui_breakpoints",
    "dapui_scopes",
}

local function merge_colors(foreground, background)
    local new_name = foreground .. background

    local hl_fg = vim.api.nvim_get_hl(0, { name = foreground })
    local hl_bg = vim.api.nvim_get_hl(0, { name = background })

    local fg = string.format("#%06x", hl_fg.fg and hl_fg.fg or 0)
    local bg = string.format("#%06x", hl_bg.bg and hl_bg.bg or 0)

    vim.api.nvim_set_hl(0, new_name, { fg = fg, bg = bg })
    return new_name
end

local function get_dap_repl_winbar(active)
    local get_mode = require("lualine.highlight").get_mode_suffix

    return function()
        local filetype = vim.bo.filetype
        local disabled_filetypes = { "dap-repl" }

        if not vim.tbl_contains(disabled_filetypes, filetype) then
            return ""
        end

        local background_color = string.format("lualine_b" .. "%s", active and get_mode() or "_inactive")

        local controls_string = "%#" .. background_color .. "#"
        for element in require("dapui.controls").controls():gmatch("%S+") do
            local color, action = string.match(element, "%%#(.*)#(%%.*)%%#0#")
            controls_string = controls_string .. " %#" .. merge_colors(color, background_color) .. "#" .. action
        end
        return controls_string
    end
end

M.winbar = {
    lualine_a = { { "filename", file_status = false } },
    lualine_b = { get_dap_repl_winbar(true) },
}

M.inactive_winbar = {
    lualine_a = { { "filename", file_status = false } },
    lualine_b = { get_dap_repl_winbar(false) },
}

return M
