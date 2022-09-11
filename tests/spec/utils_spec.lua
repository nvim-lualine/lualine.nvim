-- Copyright (c) 2020-2021 shadmansaleh
-- MIT license, see LICENSE for more details.

local helpers = require('tests.helpers')

local eq = assert.are.same
local build_component_opts = helpers.build_component_opts
local stub = require('luassert.stub')

describe('Utils', function()
  local utils = require('lualine.utils.utils')

  it('can retrive highlight groups', function()
    local hl2 = { fg = '#aabbcc', bg = '#889977', sp = '#997788', reverse = true, undercurl = true }
    -- handles non existing hl groups
    eq(utils.extract_highlight_colors('hl2'), nil)
    -- create highlight
    vim.cmd(string.format('hi hl2 guifg=%s guibg=%s guisp=%s gui=reverse,undercurl', hl2.fg, hl2.bg, hl2.sp))
    -- Can retrieve entire highlight table
    eq(utils.extract_highlight_colors('hl2'), hl2)
    -- Can retrieve specific parts of highlight
    eq(utils.extract_highlight_colors('hl2', 'fg'), hl2.fg)
    -- clear hl2
    vim.cmd('hi clear hl2')
  end)

  it('can extract individual highlight color', function()
    local fg_clr = '#aabbcc'
    local bg_clr = '#889977'
    local sp_clr = '#997788'
    local def_clr = '#ff0000'
    local hl_std = { fg = fg_clr, bg = bg_clr }
    local hl_rvs = { fg = fg_clr, bg = bg_clr, reverse = true }
    local hl_ul = { sp = sp_clr, undercurl = true }
    local hl_ul_rvs = { fg = fg_clr, bg = bg_clr, sp = sp_clr, reverse = true, undercurl = true }
    -- create highlights
    vim.cmd(string.format('hi hl_std guifg=%s guibg=%s', hl_std.fg, hl_std.bg))
    vim.cmd(string.format('hi hl_rvs guifg=%s guibg=%s gui=reverse', hl_rvs.fg, hl_rvs.bg))
    vim.cmd(string.format('hi hl_ul guisp=%s gui=undercurl', hl_ul.sp))
    vim.cmd(string.format('hi hl_ul_rvs guifg=%s guibg=%s guisp=%s gui=reverse,undercurl', hl_ul_rvs.fg, hl_ul_rvs.bg, hl_ul_rvs.sp))
    -- Can extract color from primary highlight group
    eq(utils.extract_color_from_hllist('fg', {'hl_std','hl_ul'}, def_clr), fg_clr)
    -- Can extract color from fallback highlight group
    eq(utils.extract_color_from_hllist('fg', {'hl_noexist','hl_std'}, def_clr), fg_clr)
    -- Can fall back to default color on nonexistent color
    eq(utils.extract_color_from_hllist('fg', {'hl_ul'}, def_clr), def_clr)
    -- Can fall back to default color on nonexistent highlight group
    eq(utils.extract_color_from_hllist('fg', {'hl_noexist'}, def_clr), def_clr)
    -- Can extract fallback color
    eq(utils.extract_color_from_hllist({'fg','sp'}, {'hl_ul'}, def_clr), sp_clr)
    -- Can extract reverse color
    eq(utils.extract_color_from_hllist('fg', {'hl_rvs'}, def_clr), bg_clr)
    -- Can extract fallback reverse color
    eq(utils.extract_color_from_hllist({'sp','fg'}, {'hl_rvs'}, def_clr), bg_clr)
    -- clear highlights
    vim.cmd('hi clear hl_std')
    vim.cmd('hi clear hl_rvs')
    vim.cmd('hi clear hl_ul')
    vim.cmd('hi clear hl_ul_rvs')
  end)

  it('can shrink list with holes', function()
    local list_with_holes = {
      '2',
      '4',
      '6',
      nil,
      '43',
      nil,
      '2',
      '',
      'a',
      '',
      'b',
      ' ',
    }
    local list_without_holes = { '2', '4', '6', '43', '2', 'a', 'b', ' ' }
    eq(utils.list_shrink(list_with_holes), list_without_holes)
  end)
end)

describe('Cterm genarator', function()
  local cterm = require('lualine.utils.color_utils')

  it('can convert rgb to cterm', function()
    local colors = { ['#112233'] = 235, ['#7928ae'] = 97, ['#017bdc'] = 68 }
    for rgb, ct in pairs(colors) do
      eq(cterm.rgb2cterm(rgb), tostring(ct))
    end
  end)
end)

describe('Section genarator', function()
  local hl = require('lualine.highlight')
  stub(hl, 'format_highlight')
  hl.format_highlight.returns('%#lualine_c_normal#')

  local sec = require('lualine.utils.section')
  it('can draw', function()
    local opts = build_component_opts { section_separators = { left = '', right = '' } }
    local section = {
      require('lualine.components.special.function_component')(opts),
      require('lualine.components.special.function_component')(opts),
    }
    eq('%#lualine_c_normal# test %#lualine_c_normal# test ', sec.draw_section(section, 'c', true))

    hl.format_highlight:revert()
  end)

  it('can remove separators from component with custom colors', function()
    stub(hl, 'format_highlight')
    stub(hl, 'get_lualine_hl')
    hl.format_highlight.returns('%#lualine_MySection_normal#')
    hl.get_lualine_hl.returns { fg = '#000000', bg = '#ffffff' }

    vim.g.actual_curwin = tostring(vim.api.nvim_get_current_win())
    local opts = build_component_opts { section_separators = { left = '', right = '' } }
    local opts_colored = build_component_opts { color = 'MyColor' }
    local opts_colored2 = build_component_opts {
      color = { bg = '#223344' },
      section_separators = { left = '', right = '' },
    }
    local opts_colored3 = build_component_opts {
      color = { fg = '#223344' },
      section_separators = { left = '', right = '' },
    }
    require('lualine.highlight').create_highlight_groups(require('lualine.themes.gruvbox'))
    local section = {
      require('lualine.components.special.function_component')(opts),
      require('lualine.components.special.function_component')(opts_colored),
      require('lualine.components.special.function_component')(opts),
    }
    local highlight_name2 = 'lualine_c_' .. section[2].options.component_name
    -- Removes separator on string color
    eq(
      '%#lualine_MySection_normal# test %#' .. highlight_name2 .. '#' .. ' test %#lualine_MySection_normal# test ',
      sec.draw_section(section, 'MySection')
    )
    section[2] = require('lualine.components.special.function_component')(opts_colored2)
    local highlight_name = '%#lualine_c_' .. section[2].options.component_name .. '_normal#'
    -- Removes separator on color with bg
    eq(
      '%#lualine_MySection_normal# test ' .. highlight_name .. ' test %#lualine_MySection_normal# test ',
      sec.draw_section(section, 'MySection')
    )
    section[2] = require('lualine.components.special.function_component')(opts_colored3)
    highlight_name2 = '%#lualine_c_' .. section[2].options.component_name .. '_normal#'
    -- Doesn't remove separator on color without bg
    eq(
      '%#lualine_MySection_normal# test '
        .. highlight_name2
        .. ' test %#lualine_MySection_normal#%#lualine_MySection_normal# test ',
      sec.draw_section(section, 'MySection')
    )
    vim.g.actual_curwin = nil

    hl.format_highlight:revert()
    hl.get_lualine_hl:revert()
  end)
end)
