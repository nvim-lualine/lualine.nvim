local helpers = require 'tests.helpers'

local eq = helpers.eq
local meths = helpers.meths
local build_component_opts = helpers.build_component_opts

describe('Utils', function()
  local utils = require('lualine.utils.utils')

  it('can save and restore highlights', function()
    local hl1 = {'hl1', '#122233', '#445566', 'italic', true}
    utils.save_highlight(hl1[1], hl1)
    -- highlight loaded in loaded_highlights table
    eq(utils.loaded_highlights[hl1[1]], hl1)
    -- highlight exists works properly
    eq(utils.highlight_exists('hl1'), true)
    eq(utils.highlight_exists('hl2'), false)
    -- highlights can be restored
    -- hl doesn't exist
    assert.has_error(function() meths.get_hl_by_name('hl1', true) end,
                     'Invalid highlight name: hl1')
    utils.reload_highlights()
    -- Now hl1 is created
    eq(meths.get_hl_by_name('hl1', true), {
      foreground = tonumber(hl1[2]:sub(2, #hl1[2]), 16), -- convert rgb -> int
      background = tonumber(hl1[3]:sub(2, #hl1[3]), 16), -- convert rgb -> int
      italic = true
    })
    -- highlights can be cleared
    utils.clear_highlights()
    eq(utils.highlight_exists('hl1'), false)
    -- highlight group has been cleared
    eq(meths.get_hl_by_name('hl1', true), {[true] = 6})
  end)

  it('can retrive highlight groups', function()
    local hl2 = {fg = '#aabbcc', bg = '#889977', reverse = true}
    -- handles non existing hl groups
    eq(utils.extract_highlight_colors('hl2'), nil)
    -- create highlight
    vim.cmd(
        string.format('hi hl2 guifg=%s guibg=%s gui=reverse', hl2.fg, hl2.bg))
    -- Can retrive entire highlight table
    eq(utils.extract_highlight_colors('hl2'), hl2)
    -- Can retrive specific parts of highlight
    eq(utils.extract_highlight_colors('hl2', 'fg'), hl2.fg)
    -- clear hl2
    vim.cmd 'hi clear hl2'
  end)

  it('can shrink list with holes', function()
    local list_with_holes = {
      '2', '4', '6', nil, '43', nil, '2', '', 'a', '', 'b', ' '
    }
    local list_without_holes = {'2', '4', '6', '43', '2', 'a', 'b', ' '}
    eq(utils.list_shrink(list_with_holes), list_without_holes)
  end)
end)

describe('Cterm genarator', function()
  local cterm = require 'lualine.utils.cterm_colors'

  it('can convert rgb to cterm', function()
    local colors = {['#112233'] = 235, ['#7928ae'] = 97, ['#017bdc'] = 68}
    for rgb, ct in pairs(colors) do
      eq(cterm.get_cterm_color(rgb), tostring(ct))
    end
  end)
end)

describe('Section genarator', function()
  local sec = require 'lualine.utils.section'
  it('can draw', function()
    local opts = build_component_opts()
    local section = {
      require('lua.lualine.components.special.function_component'):new(opts),
      require('lua.lualine.components.special.function_component'):new(opts)
    }
    eq('%#MyHl# test %#MyHl# test ', sec.draw_section(section, '%#MyHl#'))
  end)

  it('can remove separators from component with custom colors', function()
    local opts = build_component_opts()
    local opts_colored = build_component_opts({color = 'MyColor'})
    local opts_colored2 = build_component_opts({color = {bg = '#223344'}})
    local opts_colored3 = build_component_opts({color = {fg = '#223344'}})
    require'lualine.highlight'.create_highlight_groups(
        require 'lualine.themes.gruvbox')
    local section = {
      require('lua.lualine.components.special.function_component'):new(opts),
      require('lua.lualine.components.special.function_component'):new(
          opts_colored),
      require('lua.lualine.components.special.function_component'):new(opts)
    }
    -- Removes separator on string color
    eq('%#MyHl# test %#MyHl#%#MyColor# test %#MyHl# test ',
       sec.draw_section(section, '%#MyHl#'))
    section[2] =
        require('lua.lualine.components.special.function_component'):new(
            opts_colored2)
    local highlight_name =
        '%#lualine_c_' .. section[2].options.component_name .. '_normal#'
    -- Removes separator on color with bg
    eq('%#MyHl# test %#MyHl#' .. highlight_name .. ' test %#MyHl# test ',
       sec.draw_section(section, '%#MyHl#'))
    section[2] =
        require('lua.lualine.components.special.function_component'):new(
            opts_colored3)
    local highlight_name2 =
        '%#lualine_c_' .. section[2].options.component_name .. '_normal#'
    -- Doesn't remove separator on color without bg
    eq('%#MyHl# test %#MyHl#' .. highlight_name2 .. ' test %#MyHl# test ',
       sec.draw_section(section, '%#MyHl#'))
  end)
end)
