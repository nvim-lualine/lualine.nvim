-- Copyright (c) 2020-2021 hoob3rt
-- MIT license, see LICENSE for more details.
local require = require('lualine_require').require
local utils = require('lualine.utils.utils')
local modules = require('lualine_require').lazy_require {
  utils_notices = 'lualine.utils.notices',
}

---@alias LualineThemes
---| "auto"
---| "16color"
---| "ayu_dark"
---| "ayu_light"
---| "ayu_mirage"
---| "ayu"
---| "codedark"
---| "dracula"
---| "everforest"
---| "gruvbox_dark"
---| "gruvbox_light"
---| "gruvbox"
---| "gruvbox-material"
---| "horizon"
---| "iceberg_dark"
---| "iceberg_light"
---| "iceberg"
---| "jellybeans"
---| "material"
---| "modus-vivendi"
---| "molokai"
---| "moonfly"
---| "nightfly"
---| "nord"
---| "OceanicNext"
---| "onedark"
---| "onelight"
---| "palenight"
---| "papercolor_dark"
---| "papercolor_light"
---| "PaperColor"
---| "powerline"
---| "powerline_dark"
---| "pywal"
---| "seoul256"
---| "solarized_dark"
---| "solarized_light"
---| "Tomorrow"
---| "wombat"

---@class LualineDisabledFiletypes
---only ignores the ft for statusline
---@field statusline table
---only ignores the ft for winbar.
---@field winbar table

---@class LualineRefresh
---@field statusline integer
---@field tabline integer
---@field winbar integer

---@class LualineOpts
-- Show icons.
---@field icons_enabled boolean
-- Lualine theme name.
-- Auto theme will load the theme automaically for your colorscheme
-- or will generate one otherwise.
---@field theme LualineThemes
-- Separators between components.
---@field component_separators table|string
-- Separators between sections.
---@field section_separators table|string
-- Disable lualine for these filetypes.
---@field disabled_filetypes LualineDisabledFiletypes
-- When set to true, left sections i.e. 'a','b' and 'c'
-- can't take over the entire statusline even
-- if neither of 'x', 'y' or 'z' are present.
---@field always_divide_middle boolean
---@field globalstatus boolean
---@field refresh LualineRefresh

---@alias LualineComponents
---| "branch"
---| "buffers"
---| "diagnostics"
---| "diff"
---| "encoding"
---| "fileformat"
---| "filename"
---| "filesize"
---| "filetype"
---| "hostname"
---| "location"
---| "mode"
---| "progress`"
---| "tabs"

---@class LualineGeneralComponent
-- Must be written as array value
---@field [1] LualineComponents
-- Enables the display of icons alongside the component.
---@field icons_enabled boolean
-- Defines the icon to be displayed in front of the component.
---@field icon string
-- When a string is provided it's treated as component_separator.
-- When a table is provided it's treated as section_separator.
-- Passing an empty string disables the separator.
---@field separator string|table
-- Condition function, the component is loaded when the function returns `true`.
---@field cond fun():boolean
-- Defines a custom color for the component.
-- example: { fg = '#ffaa88', bg = 'grey', gui='italic,bold' } | { fg = 204 } | "WarningMsg"
---@field color string|table
-- Specify what type a component is.
---@field type string|table
-- Adds padding to the left and right of components.
---@field padding number
-- Format function, formats the component's output.
---@field fmt fun():string

---@class LualineColors
-- Color for active buffer.
--@field active string|table
-- Color for inactive buffer.
--@field inactive string|table

---@class LualineBuffer: LualineGeneralComponent
-- Shows shortened relative path when set to false.
---@field show_filename_only boolean
-- Shows indicator when the buffer is modified.
---@field show_modified_status boolean
-- 0: Shows buffer name
-- 1: Shows buffer index (bufnr)
-- 2: Shows buffer name + buffer index (bufnr)
---@field mode number
-- Maximum width of buffers component.
---@field max_length number|fun():number
-- Shows specific buffer name for that filetype.
---@field filetype_names table
-- Buffers colors
---@field buffers_color LualineColors

---@class LualineDiagnosticsColors
-- Diagnostics' error color.
---@field error string|table
-- Diagnostics' warn color.
---@field warn string|table
-- Diagnostics' info color.
---@field info string|table
-- Diagnostics' hint color.
---@field hint string|table

---@class LualineDiagnosticsSymbols
-- Diagnostics' error symbol (icons, then no_icons).
---@field error string
-- Diagnostics' warn symbol (icons, then no_icons).
---@field warn string
-- Diagnostics' info symbol (icons, then no_icons).
---@field info string
-- Diagnostics' hint symbol (icons, then no_icons).
---@field hint string

---@class LualineDiagnostics: LualineGeneralComponent
-- Table of diagnostic sources. Possible values:
-- 'nvim_lsp', 'nvim_diagnostic', 'coc', 'ale', 'vim_lsp',
-- fun():{error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt}
---@field sources string[]|fun():table
-- Displays diagnostics for the defined severity types.
---@field sections string[]
-- Diagnostics colors
---@field diagnostics_color LualineDiagnosticsColors
-- Diagnostics symbols
---@field symbols LualineDiagnosticsSymbols
-- Displays diagnostics status in color if set to true.
---@field colored boolean
-- Update diagnostics in insert mode.
---@field update_in_insert boolean
-- Show diagnostics even if there are none.
---@field always_visible boolean

---@class LualineDiffColors
-- Diff's added color
---@field added string|table
-- Diff's modified color
---@field modified string|table
-- Diff's removed color
---@field removed string|table

---@class LualineDiffSymbols
-- Diff's added symbol
---@field added string
-- Diff's modified symbol
---@field modified string
-- Diff's removed symbol
---@field removed string

---@class LualineDiff: LualineGeneralComponent
-- Displays a colored diff status if set to true
---@field colored boolean
-- Diff's colors
---@field diff_color LualineDiffColors
-- Diff's symbols
---@field symbols LualineDiffSymbols
-- Function that populates data for the diff
-- fun():{ added = add_count, modified = modified_count, removed = removed_count }
---@field source fun():table

---@class LualineFileformat
-- Fileformat symbols
---@field symbols table

---@class LualineFilename: LualineGeneralComponent
-- Displays file status (readonly status, modified status).
---@field file_status boolean
-- 0: Just the filename
-- 1: Relative path
-- 2: Absolute path
---@field path number
-- Shortens path to leave `n` spaces in the window
---@field shorting_target number
-- Filename symbols
---@field symbols table

---@class LualineFiletype: LualineGeneralComponent
-- Displays filetype icon in color if set to true
---@field colored boolean
-- Display only an icon for filetype
---@field icon_only boolean

---@class LualineTabs: LualineGeneralComponent
-- Maximum width of tabs component.
---@field max_length number|fun():number
-- 0: Shows tab_nr
-- 1: Shows tab_name
-- 2: Shows tab_nr + tab_name
---@field mode number
-- Tabs colors
---@field tabs_color LualineColors

---@alias LualineArrayOfComponents table<number,LualineGeneralComponent|LualineBuffer|LualineDiagnostics|LualineDiff|LualineFileformat|LualineFilename|LualineFiletype|LualineTabs>

---@alias LualineSection string[] | LualineComponents[] | fun()[] | LualineArrayOfComponents

---@alias LualineExtensions
---| "chadtree"
---| "fern"
---| "fugitive"
---| "fzf"
---| "nerdtree"
---| "nvim-tree"
---| "quickfix"
---| "toggleterm"
---| "symbols-outline"

---@alias LualineSectionGroups table<"lualine_a"|"lualine_b"|"lualine_c"|"lualine_x"|"lualine_y"|"lualine_z"|,LualineSection>

---@class LualineConfig
-- Configuration of the lualine behavior.
-- Options here are inherited by all components.
---@field options LualineOpts
-- Configuration of the status line sections for active buffers.
---@field sections LualineSectionGroups
-- Configuration of the status line sections for inactive buffers.
---@field inactive_sections LualineSectionGroups
-- Configuration of the tab line.
---@field tabline LualineSectionGroups
-- Change statusline appearance for a window/buffer with specified filetypes
---@field extensions LualineExtensions[]|string[]|table[]
local config = {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    always_divide_middle = true,
    globalstatus = vim.go.laststatus == 3,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
}

---Change separator format 'x' to {left='x', right='x'}
---
---@param separators string|table
---@return table|nil
local function fix_separators(separators)
  if separators ~= nil then
    if type(separators) == 'string' then
      return { left = separators, right = separators }
    end
  end
  return separators
end

---copy raw disabled_filetypes to inner statusline & winbar tables.
---@param disabled_filetypes table
---@return LualineFiletype|nil
local function fix_disabled_filetypes(disabled_filetypes)
  if disabled_filetypes == nil then
    return
  end
  if disabled_filetypes.statusline == nil then
    disabled_filetypes.statusline = {}
  end
  if disabled_filetypes.winbar == nil then
    disabled_filetypes.winbar = {}
  end
  for k, disabled_ft in ipairs(disabled_filetypes) do
    table.insert(disabled_filetypes.statusline, disabled_ft)
    table.insert(disabled_filetypes.winbar, disabled_ft)
    disabled_filetypes[k] = nil
  end
  return disabled_filetypes
end

---Extends config based on config_table.
---
---@param config_table LualineConfig
---@return LualineConfig
local function apply_configuration(config_table)
  if not config_table then
    return utils.deepcopy(config)
  end
  local function parse_sections(section_group_name)
    if config_table[section_group_name] == nil then
      return
    end
    if not next(config_table[section_group_name]) then
      config[section_group_name] = {}
      return
    end
    for section_name, section in pairs(config_table[section_group_name]) do
      config[section_group_name][section_name] = utils.deepcopy(section)
    end
  end
  if config_table.options and config_table.options.globalstatus and vim.fn.has('nvim-0.7') == 0 then
    modules.utils_notices.add_notice(
      '### Options.globalstatus\nSorry `globalstatus` option can only be used in neovim 0.7 or higher.\n'
    )
    config_table.options.globalstatus = false
  end
  if vim.fn.has('nvim-0.8') == 0 and (next(config_table.winbar or {}) or next(config_table.inactive_winbar or {})) then
    modules.utils_notices.add_notice('### winbar\nSorry `winbar can only be used in neovim 0.8 or higher.\n')
    config_table.winbar = {}
    config_table.inactive_winbar = {}
  end
  parse_sections('options')
  parse_sections('sections')
  parse_sections('inactive_sections')
  parse_sections('tabline')
  parse_sections('winbar')
  parse_sections('inactive_winbar')
  if config_table.extensions then
    config.extensions = utils.deepcopy(config_table.extensions)
  end
  config.options.section_separators = fix_separators(config.options.section_separators)
  config.options.component_separators = fix_separators(config.options.component_separators)
  config.options.disabled_filetypes = fix_disabled_filetypes(config.options.disabled_filetypes)
  return utils.deepcopy(config)
end

---Returns current active config.
---@return LualineConfig
local function get_current_config()
  return utils.deepcopy(config)
end

return {
  get_config = get_current_config,
  apply_configuration = apply_configuration,
}
